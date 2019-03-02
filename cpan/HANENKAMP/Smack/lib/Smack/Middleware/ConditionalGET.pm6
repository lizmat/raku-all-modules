use v6;

use Smack::Middleware;

unit class Smack::Middleware::ConditionalGET is Smack::Middleware;

use Smack::Util;

method call(%env) {
    return callsame() unless %env<REQUEST_METHOD> eq 'GET' | 'HEAD';

    callsame() then-with-response sub ($s, @h, $e) {
        my @checks = self.etag-matches(@h, %env),
                     self.not-modified-since(@h, %env);

        return unless @checks;
        return unless all(@checks);

        my @head = @h.grep({
            .key ne 'Content-Type' | 'Content-Length' | 'Content-Disposition'
        });

        # 304 with content headers stripped, and empty body
        304, @head, $e.map({ '' })
    }
}

sub _value($str is copy) { s/';' .* $// with $str; $str//Nil }

method etag-matches(@h, %env) {
    my $etag = @h.first({ .key.lc eq 'etag' });
    with $etag {
        .value ~~ _value(%env<HTTP_IF_NONE_MATCH>);
    }
    else {
        Empty;
    }
}

method not-modified-since(@h, %env) {
    my $last-modified = @h.first({ .key.lc eq 'last-modified' });
    with $last-modified {
        .value ~~ _value(%env<HTTP_IF_MODIFIED_SINCE>);
    }
    else {
        Empty;
    }
}
