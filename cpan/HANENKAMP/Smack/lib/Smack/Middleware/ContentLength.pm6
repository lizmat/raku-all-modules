use v6;

use Smack::Middleware;

unit class Smack::Middleware::ContentLength
is Smack::Middleware;

use Smack::Util;

method call(%env) {
    callsame() then-with-response -> $s, @h, $entity {
        my $headers = response-headers(@h, :%env);

        if !status-with-no-entity-body($s)
            && !$headers.Content-Length
            && !$headers.Transfer-Encoding
            && !$entity.live {

            my $cl = content-length(%env, $entity).Promise;
            my $content-length = await $cl;

            push @h, 'Content-Length' => $content-length;
        }

        $s, @h, $entity
    }
}
