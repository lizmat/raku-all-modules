use Cro::HTTP::Auth;
use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::OpenAPI::RoutesFromDefinition;
use Cro::OpenAPI::RoutesFromDefinition::SecurityChecker;
use OpenAPI::Model;
use Test;

my constant TEST_PORT = 30005;

my $api-doc = q:to/OPENAPI/;
    {
        "openapi": "3.0.0",
        "info": {
            "version": "1.0.0",
            "title": "Cro Test Case"
        },
        "components": {
            "securitySchemes": {
                "api_key": {
                  "type": "apiKey",
                  "name": "X-APIKey",
                  "in": "header"
                }
            }
        },
        "paths": {
            "/public": {
                "get": {
                    "summary": "Public operation",
                    "operationId": "public"
                }
            },
            "/private": {
                "get": {
                    "summary": "Private operation",
                    "operationId": "private",
                    "security": [
                        {
                            "api_key": []
                        }
                    ]
                }
            }
        }
    }
    OPENAPI

class MyAuthInfo does Cro::HTTP::Auth {
    has $.key;
}

class KeyChecker does Cro::OpenAPI::RoutesFromDefinition::SecurityChecker {
    method is-allowed(OpenAPI::Model::SecurityScheme $scheme, Cro::HTTP::Request $request --> Bool) {
        with self.get-api-key($scheme, $request) -> $key {
            if $key.starts-with('totally-legit') {
                $request.auth = MyAuthInfo.new(:$key);
                return True;
            }
        }
        return False;
    }
}

my $application = openapi $api-doc, security => KeyChecker, {
    operation 'public', -> {
        content 'text/plain', 'public ok';
    }
    operation 'private', -> {
        content 'text/plain', 'private ok, key=' ~ request.auth.key;
    }
}

my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
$server.start;
my $uri = "http://127.0.0.1:{TEST_PORT}";

{
    my $resp = await Cro::HTTP::Client.get: "$uri/public";
    is $resp.status, 200, 'Can make a request to /public without an API key';
    is await($resp.body-text), 'public ok', 'Correct response body from /public';
}

{
    my $resp = await Cro::HTTP::Client.get: "$uri/private",
            headers => { X-APIKey => 'totally-legit-foo' };
    is $resp.status, 200, 'Can make a request to /private with an API key';
    is await($resp.body-text), 'private ok, key=totally-legit-foo',
            'Correct response body from /private with key';
}

throws-like
    {
        await Cro::HTTP::Client.get: "$uri/private"
    },
    X::Cro::HTTP::Error,
    response => { .status == 401 },
    'When no auth header, 401 error';


throws-like
    {
        await Cro::HTTP::Client.get: "$uri/private",
                headers => { X-APIKey => 'totally-fake-foo' }
    },
    X::Cro::HTTP::Error,
    response => { .status == 401 },
    'When API key does not match, 401 error';

done-testing;
