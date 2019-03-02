use v6;

use Smack::Middleware;

unit class Smack::Middleware::PSGI is Smack::Middleware;

method call(%env) {
    my $encoding =

    my class InputWrapper {
        has $.input;

        has $!buffer = buf8.new;
        has Bool $!eof = False;
        has Int $!read-head = 0;
        has Channel $!pinger;

        submethod BUILD(:$!input) {
            $!pinger .= new;
            $!input.tap:
                -> $b { $!buffer ~= $b; $!pinger.send(True); },
                done => { $!eof = True; $!pinger.send(True); },
            ;
        }

        multi method read(Blob $buf is rw, $len, $offset = 0) {
            while $!read-head >= $!buffer.elems {
                return 0 if $!eof;
                await $!pinger;
            }

            $buf = $!buffer.subbuf($!read-head + $offset, $len);
            my $new-read-head = $!read-head + $offset + $len min $!buffer.elems;
            my $bytes = $new-read-head - $!read-head;
            $!read-head = $new-read-head;

            $bytes;
        }
        multi method read($buf is rw, $len, $offset = 0) {
            callwith(Proxy.new(
                FETCH => method ($blob) { $buf.encode($encoding) },
                STORE => method ($blob) { $buf = $blob.decode($encoding) },
            ) but Blob, $len, $offset);
        }
        multi method seek($pos, $whence = 0) {
            given $whence {
                when 0 { $!read-head  = $pos }
                when 1 { $!read-head += $pos }
                when 2 { $!read-head  = $!buffer.elems + $pos }
                default { die "illegal whence given to seek" }
            }
        }
    }

    my $input = InputWrapper.new(input => %env<p6w.input>);

    # Install PSGI environment
    %env = %env,
        'psgi.version'      => [ 1, 1 ],
        'psgi.url_scheme'   => %env<p6w.url-scheme>,
        'psgi.input'        => $input,
        'psgi.errors'       => %env<p6w.errors>,
        'psgi.multithread'  => %env<p6w.multithread>,
        'psgi.multiprocess' => %env<p6w.multiprocess>,
        'psgi.run_once'     => %env<p6w.run-once>,
        'psgi.nonblocking'  => %env<p6w.nonblocking>,
        'psgi.streaming'    => True,
        ;

    do given &.app.(%env) {
        when Positional { Promise.new(:result($_)) }
        when Callable {
            my @response;

            start {
                .(-> @res {
                    if @res.elems == 3 {
                        @response = @res;
                    }
                    elsif @res.elems == 2 {
                        my Channel $q .= new;

                        @response = @res[0, 1].Slip, Supply.on-demand(-> $s {
                            loop {
                                my $t = $q.receive;
                                $s.emit($t);
                            }

                            CATCH {
                                when X::Channel::ReceiveOnClosed {
                                    $s.done;
                                }
                            }
                        });

                        my $writer = class {
                            multi method write(Str $str) { $q.send($str) }
                            multi method write(Blob $b)  { $q.send($b) }
                            multi method close()         { $q.close }
                        }.new;
                    }
                    else {
                        die 'Wrong number of elements in application response.';
                    }
                });

                @response;
            }
        }
        default {
            die 'Unknown application response: ', .perl;
        }
    }
}
