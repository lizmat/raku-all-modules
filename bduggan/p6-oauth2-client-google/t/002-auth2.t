use v6;
use lib 'lib';
use Test;

use OAuth2::Client::Google;

my $sample-config =
{
  "web" => {
    "redirect_uris" => [
      "http://localhost:3334/oauth",
    ],
    "client_secret" => "some_secret",
    "auth_provider_x509_cert_url" => "https://example.com/certs",
    "token_uri" => "https://accounts.google.com/o/oauth2/token",
    "auth_uri" => "https://accounts.google.com/o/oauth2/auth",
    "project_id" => "some-projectid-1234",
    "client_id" => "some-client-id"
  }
}

my $o = OAuth2::Client::Google.new(
    config => $sample-config,
    redirect-uri => 'http://example.com/here',
    scope => 'email',
);
ok $o, 'made an object';

is $o.auth-uri, <
    https://accounts.google.com/o/oauth2/auth?access_type=
    client_id=some-client-id
    include_granted_scopes=true
    login_hint=
    prompt=consent
    redirect_uri=http://example.com/here
    response_type=code
    scope=email
state=>.join('&'), 'got auth-uri';

ok $o.code-to-token(:code("1234")), 'called code-to-token';

done-testing;
