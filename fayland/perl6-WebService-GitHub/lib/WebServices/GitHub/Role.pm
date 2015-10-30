use v6;

use URI;
use URI::Escape;
use MIME::Base64;
use JSON::Fast; # from-json
use HTTP::Request;
use HTTP::UserAgent;
use WebServices::GitHub::Response;

role WebServices::GitHub::Role {
    has $.endpoint = 'https://api.github.com';
    has $.access-token;
    has $.auth_login;
    has $.auth_password;

    has $.useragent = 'perl6-WebService-GitHub/0.1.0';
    has $.ua = HTTP::UserAgent.new;

    # request args
    has $.per_page;
    has $.jsonp_callback;
    has $.time-zone;
    has $.media-type is rw;

    # response args
    has $.auto_pagination = 0;

    has %.role_data;

    method request(Str $path, $method='GET', :%data is copy) {
        my $url = $.endpoint ~ $path;
        if ($method eq 'GET') {
            %data<per_page> = $.per_page if $.per_page.defined;
            %data<callback> = $.jsonp_callback if $.jsonp_callback.defined;
            # dummy, not supported
            # $uri.query_form(|%data);
            $url ~= '?' ~ (for %data.kv -> $k, $v {
                $k ~ '=' ~ uri-escape($v)
            }).join('&') if %data.elems;
        }

        my $uri = URI.new($url);
        my $request = HTTP::Request.new(|($method => $uri));
        $request.header.field(User-Agent => $.useragent);
        if $.media-type.defined {
            $request.header.field(Accept => $.media-type);
        } else {
            $request.header.field(Accept => 'application/vnd.github.v3+json');
        }

        if $.time-zone.defined {
            $request.header.field(
                Time-Zone => $.time-zone
            );
        }

        if $.auth_login.defined && $.auth_password.defined {
            $request.header.field(
                Authorization => "Basic " ~ MIME::Base64.encode-str("{$.auth_login}:{$.auth_password}")
            );
        } elsif ($.access-token) {
            $request.header.field(
                Authorization => "token " ~ $.access-token
            );
        }

        if ($method ne 'GET' and %data) {
            $request.content = to-json(%data).encode;
            $request.header.field(Content-Length => $request.content.bytes.Str);
        }

        $request = $.prepare_request($request);
        my $res = $.ua.request($request);
        $res = $.handle_response($res);

        return WebServices::GitHub::Response.new(
            raw => $res,
            auto_pagination => $.auto_pagination,
        );
    }

    # for role override
    method prepare_request($request) { return $request }
    method handle_response($response) { return $response }
}
