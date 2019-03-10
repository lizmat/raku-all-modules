use v6;

use Smack::Middleware;

unit class Smack::Middleware::ContentLength
is Smack::Middleware;

use Smack::Util;

method call(%env) {
    callsame() then-with-response -> $s, @h, $entity is copy {
        my $headers = response-headers(@h, :%env);

        if !status-with-no-entity-body($s)
            && !$headers.Content-Length
            && !$headers.Transfer-Encoding
            && !$entity.live {

            my Promise $cl;
            $entity = content-length(%env, $entity, $cl);
            my $content-length = await $cl;

            push @h, 'Content-Length' => $content-length;
        }

        $s, @h, $entity
    }
}
