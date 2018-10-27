use v6;

use URI;
use URI::Escape;
use MIME::Base64;
use JSON::Fast; # from-json
use Cache::LRU;
use HTTP::Request;
use HTTP::UserAgent;
use WebService::GitHub::Response;

class X::WebService::GitHub is Exception {
  has $.reason;
  method message()
  {
    "Error : $.reason";
  }
}

role WebService::GitHub::Role {
    has $.endpoint = 'https://api.github.com';
    has $.access-token= %*ENV<GH_TOKEN>;
    has $.auth_login;
    has $.auth_password;

    has $.useragent = 'perl6-WebService-GitHub/0.1.0';
    has $.ua = HTTP::UserAgent.new;

    has $.cache = Cache::LRU.new(size => 200);

    # request args
    has $.per_page;
    has $.jsonp_callback;
    has $.time-zone;
    has $.media-type is rw;

    # response args
    has $.auto_pagination = 0;

    has @.with = ();
    has %.role_data;

    submethod BUILD(*%args) {
        if %args<with>:exists {
            for %args<with> -> $n {
                my $class = "WebService::GitHub::Role::$n";
                require ::($class);
                self does ::($class);
            }
        }

# does not work
#   for %args.kv -> $k, $value {
#       self."$k"( $value );
#   }
        # backwards
        $!access-token  = %args<access-token>  if %args<access-token>:exists;
        $!auth_login    = %args<auth_login>    if %args<auth_login>:exists;
        $!auth_password = %args<auth_password> if %args<auth_password>:exists;
        $!endpoint      = %args<endpoint>      if %args<endpoint>:exists;
    }

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
        my $res = self._make_request($request);
	        $res = $.handle_response($res);

        my $ghres = WebService::GitHub::Response.new(
          raw => $res,
          auto_pagination => $.auto_pagination,
        );

        if (!$ghres.is-success && $ghres.data<message>) {
          my $message = $ghres.data<message>;
          my $errors =  $ghres.data<errors>;
          if ($errors[0]{"message"}) {
            $message = $message ~ ' - ' ~ $errors[0]{"message"};
          }
          X::WebService::GitHub.new(reason => $message).throw;
        }

        return $ghres;
    }

    method _make_request($request) {
        ## only support GET
        if $request.method ne 'GET' {
            return $.ua.request($request);
        }

        my $cached_res = $.cache.get($request.file);
        if $cached_res {
            # $request.header.field(
            #     If-None-Match => $cached_res.field('ETag').Str
            # );
            $request.header.field(
                If-Modified-Since => $cached_res.field('Last-Modified').Str
            );

            my $res = $.ua.request($request);
            if $res.code == 304 {
                return $cached_res;
            }

            $.cache.set($request.file, $res);
            return $res;
        } else {
            my $res = $.ua.request($request);
            $.cache.set($request.file, $res);
            return $res;
        }
    }

    # for role override
    method prepare_request($request) { return $request }
    method handle_response($response) { return $response }
}
