use v6;

use Smack::Handler;

unit class Smack::Handler::CGI
does Smack::Handler;

use HTTP::Status;

method run(&app) {
    my Promise $sent .= new;
    my $vow = $sent.vow;

    my %env = %*ENV,
        'p6sgi.version'         => Version.new('0.4.Draft'),
        'p6sgi.inputs'          => $*IN,
        'p6sgi.errors'          => $*ERR,
        'p6sgi.url-scheme'      => %*ENV<HTTPS>//'off' ~~ any('on', '1') ?? 'https' !! 'http',
        'p6sgi.run-once'        => True,
        'p6sgi.multithread'     => False,
        'p6sgi.multiprocess'    => True,
        'p6sgi.nonblocking'     => False,
        'p6sgi.input.buffered'  => False,
        'p6sgi.errors.buffered' => True,
        'p6sgi.encoding'        => 'UTF-8',
        'p6sgix.output.sent'    => $sent,
        ;

    %env<HTTP_CONTENT_TYPE>:delete;
    %env<HTTP_CONTENT_LENGTH>:delete;
    %env<HTTP_COOKIE> ||= %env<COOKIE>; # O'Reilly server bug

    if %env<PATH_INFO> :!exists {
        %env<PATH_INFO> = '';
    }

    if %env<SCRIPT_NAME>//'' eq '/' {
        %env<SCRIPT_NAME> = '';
        %env<PATH_INFO>   = '/' ~ %env<PATH_INFO>;
    }

    await app(%env).then(-> $p {
        my (Int(Any) $status, $headers, Supply(Any) $body) = $p.result;
        self.handle-response($status, $headers, $body, $vow);
    });
}

method handle-response(Int $status, @headers, Supply $body, $vow) {
    my $status-msg = get_http_status_msg($status);

    # Header SHOULD be ASCII or ISO-8859-1, in theory, right?
    $*OUT.write("Status: $status $status-msg\x0d\x0a".encode('ISO-8859-1'));
    $*OUT.write("{.key}: {.value}\x0d\x0a".encode('ISO-8859-1')) for @headers;
    $*OUT.write("\x0d\x0a".encode('ISO-8859-1'));
    $*OUT.flush;

    # Detect encoding
    my $ct = @headers.first(*.key.lc eq 'content-type');
    my $charset = $ct.value.comb(/<-[;]>/)».trim.first(*.starts-with("charset="));
    $charset.=substr(8) if $charset;
    $charset //= 'UTF-8';

    my $encoded = False;
    $body.tap(
        -> $v {
            my Blob $buf = do given ($v) {
                when Cool { $encoded = True; $v.Str.encode($charset) }
                when Blob { $v }
                default {
                    warn "Application emitted unknown message.";
                    Nil;
                }
            }
            $*OUT.write($buf) if $buf;
        },
        done => { $vow.keep(Any) },
        quit => {
            my $x = $_;
            CATCH {
                # this is stupid, IO::Socket needs better exceptions
                when "Not connected!" {
                    # ignore it
                }
            }
            $vow.break($x);
        },
    );

    # stop here until done so we can finish
    $body.wait;
    $*OUT.flush;
}
