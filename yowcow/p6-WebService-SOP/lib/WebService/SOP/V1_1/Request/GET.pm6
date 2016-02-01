use v6;
use HTTP::Request::Common;
use URI::Escape;
use WebService::SOP::V1_1::Util;

unit class WebService::SOP::V1_1::Request::GET;

method create-request(URI :$uri, Hash:D :$params, Str:D :$app-secret --> HTTP::Request) {

    die '`time` is required in params' if not $params<time>:exists;

    my %query = %( $uri.query-form, %$params );
    %query<sig> = create-signature(%query, $app-secret);

    my Str $query-string = (for %query.kv -> $k, $v {
        uri-escape($k) ~ '=' ~ uri-escape($v)
    }).join("&");

    GET(URI.new("{$uri.scheme}://{$uri.host}{$uri.path}?{$query-string}"));
}
