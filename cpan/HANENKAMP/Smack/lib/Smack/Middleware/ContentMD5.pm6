use v6;

use Smack::Middleware;

unit class Smack::Middleware::ContentMD5
is Smack::Middleware;

use Digest::MD5;
use Smack::Util;

method call(%env) {
    callsame() then-with-response -> $s, @h, $entity {
        my $headers = response-headers(@h, :%env);

        if !status-with-no-entity-body($s)
            && !$headers.Content-MD5
            && !$entity.live {

            my $md5-sum-p
                = $entity.grep(Blob | Str)
                            .map({ stringify-encode($_, :%env) })
                            .reduce({ $^a ~ $^b })
                            .map({
                            Digest::MD5::md5($_).list».fmt('%02x').join;
                            })
                            .Promise
                            ;

            my $md5-sum = await $md5-sum-p;

            push @h, 'Content-MD5' => $md5-sum;
        }

        $s, @h, $entity
    }
}
