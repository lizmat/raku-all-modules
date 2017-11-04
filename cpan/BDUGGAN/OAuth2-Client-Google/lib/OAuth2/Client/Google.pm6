unit class OAuth2::Client::Google;
use HTTP::UserAgent;
use JSON::Fast;

# Reference:
# https://developers.google.com/identity/protocols/OAuth2WebServer

has $.config;
has Str:D $.redirect-uri is required;
has $.response-type = 'code';
has $.prompt = 'consent'; # or none or select_account or "consent select_account";
has $.include-granted-scopes = 'true';
has $.scope is required;
has $.state = "";
has $.login-hint = "";
has $.access-type = ""; # online offline

method !client-id { $.config<web><client_id> }
method !client-secret { $.config<web><client_secret> }

method auth-uri {
    my $web-config = $.config<web>;
    die "missing client_id" unless $web-config<client_id>;
    return $web-config<auth_uri> ~ '?' ~
     ( response_type          => $.response-type,
        client_id              => self!client-id,
        redirect_uri           => $.redirect-uri,
        scope                  => $.scope,
        state                  => $.state,
        access_type            => $.access-type,
        prompt                 => $.prompt,
        login_hint             => $.login-hint,
        include_granted_scopes => $.include-granted-scopes,
     ).sort.map({ "{.key}={.value}" }).join('&');
}

# Send a request to <https://www.googleapis.com/oauth2/v4/token>.
#
# Returns:
#
# access_token  The token that can be sent to a Google API.
# refresh_token A token that may be used to obtain a new access
#                 token. Refresh tokens are valid until the user revokes access.
#                 This field is only present if access_type=offline is included
#                 in the authorization code request.
# expires_in 	 The remaining lifetime of the access token.
# token_type 	 Identifies the type of token returned.
#                 At this time, this field will always have the value Bearer.
# id_token      If you ask for email/profile scopes.
# or
#    error
#    error_description
#
method code-to-token(:$code!) {
    my %payload =
        code => $code,
        client_id => self!client-id,
        client_secret => self!client-secret,
        redirect_uri => $.redirect-uri,
        grant_type => 'authorization_code';
    my $ua = HTTP::UserAgent.new;
    my $res = $ua.post("https://www.googleapis.com/oauth2/v4/token", %payload);
    $res.is-success or return { error => $res.status-line };
    return from-json($res.content);
}

# Given an id token from code-to-token verify it and return data about the user.
#
# From https://developers.google.com/identity/sign-in/web/backend-auth, it should contain:
#
# "iss": "https://accounts.google.com",
# "sub": "110169484474386276334",
# "azp": "1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
# "aud": "1008719970978-hb24n2dstb40o45d4feuo2ukqmcc6381.apps.googleusercontent.com",
# "iat": "1433978353",
# "exp": "1433981953",
#
# // These seven fields are only included when the user has granted the "profile" and
# // "email" OAuth scopes to the application.
# "email": "testuser@gmail.com",
# "email_verified": "true",
# "name" : "Test User",
# "picture": "https://lh4.googleusercontent.com/-kYgzyAWpZzJ/ABCDEFGHI/AAAJKLMNOP/tIXL9Ir44LE/s99-c/photo.jpg",
# "given_name": "Test",
# "family_name": "User",
# "locale": "en"
#
# It also seems to have other stuff.
method verify-id(Str:D :$id-token!) {
    my $ua = HTTP::UserAgent.new;
    my $res = $ua.get("https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=$id-token");
    $res.is-success or return { error => $res.status-line };
    my $got = from-json($res.content);
    return { error => "client id mismatch" } unless $got<aud> eq self!client-id;
    return $got;
}

=begin pod

=head1 NAME

OAuth2::Client::Google -- Authenticate with Google using OAuth2.

=head1 Quick how-to

1. Go to http://console.developers.google.com and create a project.

2. Set up credentials for a web server and set your redirect URIs.

3. Download the JSON file (client_id.json).

4. In your application, create an oauth2 object like this:

=begin code
        my $oauth = OAuth2::Client::Google.new(
            config => from-json('./client_id.json'.IO.slurp),
            redirect-uri => 'http://localhost:3334/oauth',
            scope => 'email'
        );
=end code

where redirect-uri is one of your redirect URIs and
scope is a space or comma-separated list of scopes
from <https://developers.google.com/identity/protocols/googlescopes>.

To authenticate, redirect the user to

    $oauth.auth-uri

Then when they come back and send a request to '/oauth', grab
the "code" parameter from the query string.  Use it to
call

    my $token = $oauth.code-to-token(code => $code)

This will give you `$token<access_token>`, which you can
then use with google APIs.

If you also included "email" in the scope, you will get id-token,
which you can use like this:

    my $identity = $oauth.verify-id(id-token => $token<id_token>)

which has, e.g. `$identity<email>` and `$identity<given_name>`.

For a working example, see [eg/get-calendar-data.p6](eg/get-calendar-data.p6).

=head1 STATUS

[![Build Status](https://travis-ci.org/bduggan/p6-oauth2-client-google.svg?branch=master)](https://travis-ci.org/bduggan/p6-oauth2-client-google)

=head1 SEE ALSO

https://developers.google.com/identity/protocols/OAuth2WebServer

=head1 TODO

* Better documentation

* Refresh tokens

=end pod
