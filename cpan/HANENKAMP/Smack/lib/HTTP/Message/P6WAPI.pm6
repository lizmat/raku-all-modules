use v6;

unit module HTTP::Message::P6WAPI;

use HTTP::Request;
use HTTP::Response;
use HTTP::Status;

sub request-to-p6wapi(HTTP::Request $req, :env(%overrides), :%config) is export {
    use URI::Escape;

    my $uri = $req.uri;

    my $errors-to-err = Supplier.new;
    $errors-to-err.Supply.tap: { $*ERR.say($^msg) }

    my %fields = gather for $req.header.header-field-names -> $field {
        my $key = "HTTP_{$field.uc.trans('-' => '_')}";
        $key ~~ s/^ HTTP_ //
            if $field eq 'Content-Length' | 'Content-Type';

        take $key => $req.header.field($field).Str;
    }

    my %env =
        |%fields,
        |%config,
        PATH_INFO              => uri-unescape($uri.path),
        QUERY_STRING           => $uri.query // '',
        SCRIPT_NAME            => '',
        SERVER_NAME            => $uri.host,
        SERVER_PORT            => $uri.port,
        SERVER_PROTOCOL        => $req.protocol // 'HTTP/1.1',
        REMOTE_ADDR            => '127.0.0.1',
        REMOTE_HOST            => 'localhost',
        REMOTE_PORT            => (rand * 64000 + 1024).Int,
        REQUEST_URI            => $uri.path-query,
        REQUEST_METHOD         => $req.method,
        |%overrides;
        ;

    if %env<SCRIPT_NAME> {
        %env<PATH_INFO> ~~ s/^ "%env<SCRIPT_NAME>" /\//;
        %env<PATH_INFO> ~~ s/^ "/"+ /\//;
    }

    if !defined(%env<HTTP_HOST>) && $req.uri.host {
        %env<HTTP_HOST> = $req.uri.host;
        %env<HTTP_HOST> ~= ":$req.uri.port()"
            if $req.uri.port != $req.uri.default-port;
    }

    %env;
}

proto response-from-p6wapi(|) is export { * }
multi response-from-p6wapi(Promise:D $p6w-promise) is export {
    samewith(await $p6w-promise);
}

constant CR   = 0x0d;
constant LF   = 0x0a;
constant CRLF = utf8.new(CR, LF);

multi response-from-p6wapi(@p6w-res (Int() $status, @headers, Supply() $entity)) is export {
    my HTTP::Response $res .= new($status);
    $res.header.field: |$_ for @headers;
    $res.set-code($status);

    my $encoding = $res.charset;

    unless $res.is-text {
        $res.content = buf8.new;
    }

    react {
        whenever $entity -> $buf {
            given $buf {
                when Blob {
                    if $res.is-text {
                        $res.add-content($buf)
                    }
                    else {
                        $res.add-content($buf.decode($encoding));
                    }
                }
                when List {
                    $res.add-content(CRLF);
                    $res.add-content(CRLF);
                    for $buf.kv -> $field, $value {
                        $res.add-content("$field: $value".encode('ISO-8859-1'));
                        $res.add-content(CRLF);
                    }
                }
                when Associative { #`{ ignore for this purpose } }
                default {
                    if $res.is-text {
                        $res.add-content($buf);
                    }
                    else {
                        $res.add-content("$buf".encode($encoding));
                    }
                }
            }
        }
    }

    $res.content = '' if not $res.is-text
                     and $res.content.bytes == 0;

    $res;
}
