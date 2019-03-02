use v6;

unit class Smack::Middleware::Chunked
does Smack::Middleware;

use HTTP::Headers;
use Smack::Util;

method call(%env) {
    return &.app(%env) if %env<SERVER_PROTOCOL> eq 'HTTP/1.0';

    &.app.(%env).then(-> $p {
        my ($s, @h, Supply(All) $body) = $p.result;

        my $headers = response-headers(@h, :%env);
        return $p.result if any($headers<Content-Length Transfer-Encoding> :exists);

        my $charset = response-encoding(:$headers, :%env);

        my $CRLF = "\x0d\x0a".encode($charset);

        $headers.Transfer-Encoding = 'chunked';
        $s, @h, Supply.on-demand(-> $b {
            $body.tap(
                -> $chunk is copy {
                    $chunk = stringify-encode($chunk, :$headers, :%env);

                    $b.emit(
                        [~] sprintf('%x', $chunk.bytes).encode($charset),
                            $CRLF, $chunk, $CRLF
                    ) if $chunk.bytes;
                },
                done => {
                    $b.emit("0\x0d\x0a\x0d\x0a");
                    $b.done;
                },
            );
            $body.wait;
        });
    });
}
