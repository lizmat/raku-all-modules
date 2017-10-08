use v6;
use HTTP::Request::Common;
use URI;
use URI::Escape;
use WebService::SOP::V1_1::Util;

unit class WebService::SOP::V1_1::Request::GET;

method create-request(URI :$uri, Hash:D :$params, Str:D :$app-secret --> HTTP::Request) {

    die '`time` is required in params' if not $params<time>:exists;

    my %query = %( $uri.query-form, %$params );
    %query<sig> = create-signature(%query, $app-secret);

    GET(URI.new("{$uri.scheme}://{$uri.host}{$uri.path}?{build-query-string(%query)}"));
}
