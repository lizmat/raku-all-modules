use v6;

use Smack::Middleware;

unit class Smack::Middleware::ErrorDocument is Smack::Middleware;

use HTTP::Status;
use Smack::MIME;
use Smack::Util;

has Bool $.subrequest = False;
has %.error-documents{Int};

multi method new(%error-documents, Bool :$subrequest, |args) {
    self.bless(:%error-documents, :$subrequest, |args);
}

method call(%env) {
    callsame() then-with-response sub ($s, @h, $e) {
        return unless is-error($s) && %.error-documents{$s};

        my $path = %.error-documents{$s};
        if $.subrequest {
            for %env.kv -> $key, $value {
                unless $key ~~ /^p6w/ {
                    %env{"p6wx.errordocument.$key"} = $value;
                }
            }

            %env<REQUEST_METHOD> = 'GET';
            %env<REQUEST_URI>    = $path;
            %env<PATH_INFO>      = $path;
            %env<QUERY_STRING>   = '';
            %env<CONTENT_LENGTH> :delete;

            await self.app.(%env) then-with-response -> $sub-s, @sub-h, $sub-e {
                if $sub-s == 200 {
                    $s, @sub-h, $sub-e;
                }
                else {
                    $s, @h, $e;
                }
            }
        }
        else {
            header-remove(@h, 'Content-Length');
            header-remove(@h, 'Content-Encoding');
            header-remove(@h, 'Transfer-Encoding');
            header-set(@h, Content-Type => Smack::MIME.mime-type($path));

            open($path, :bin).Supply
        }
    }
}
