use v6;

unit class Smack::Middleware::Protocol::HTTP1;

use HTTP::Parser;

my enum ReqState < NewConn Head Body NotHTTP1 >;

has ReqState $!state = NewConn;

has Bool $.server-mode = False;

constant MY-PROTOCOLS = set <HTTP/1.0 HTTP/1.1>;

my class X::Smack::Middleware::Protocol::HTTP1::ProtocolMismatch is Exception {
    method message() { 'HTTP version not supported' }
}

method call(%env) {
    react {
        my Buf $buf .= new;

        # Make a copy of input, we will replace it shortly
        my Supply  $conn = %env<p6w.input>;

        # This will hold the env/response pipeline for the connection
        my @pipeline;

        my Bool $perist = True;
        my Bool $serving = False;

        whenever $conn -> Blob $chunk {
            given $!state {
                when NewConn {
                    $!state = Head;
                    proceed;
                }
                when Head {
                    $buf ~= $chunk;
                    if my %new-env = self!parse-head(%env, $buf) {
                        $!state = Body;
                        %env<p6w.input> = %new-env<p6w.input> = Supply.new;
                        push @pipeline, [ %new-env, $.app.(%new-env) ];
                        proceed;
                    }

                    CATCH {
                        when X::Smack::Middleware::Protocol::HTTP1::ProtocolMismatch {
                            %env<p6w.protocols.tried> ∪= MY-PROTOCOL;
                            my $has-remaining = (
                                %env<p6w.protocols.supported> ∖ %env<p6w.protocols.tried>
                            ).elems > 0;

                            if $has-remaining {
                                %env<p6w.input> = Supply.new;
                                push @pipeline, [ %env, $.app.(%env) ];
                                $!state = NotHTTP1;
                                proceed;
                            }
                            else {
                                # All done. Just quit.
                                return 505,
                                    [ Content-Type => 'text/plain' ],
                                    [ .message ],
                                    ;
                            }
                        }
                    }
                }
                when Body {
                    if %env<CONTENT_LENGTH> ~~ Int:D {
                        if %env<smack.mw.protocol.http1.bytes>
                        my $total-bytes = %env<smack.mw.protocol.http1.bytes> + $buf.bytes + $chunk.bytes;
                    %env<p6w.input>.emit: $buf;
                    $buf .= new;
                    %env<p6w.input>.emit: $chunk;
                }
                when NotHTTP1 {
                    my (%env, $r)
                    %env<p6w.input>.emit: $buf if $buf.elems;
                    $buf .= new;
                    %env<p6w.input>.emit: $chunk;
                }
            }
        }
    }
}

method !parse-head(%env is copy, $buf is rw) {

}
