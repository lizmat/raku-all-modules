use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::OpenAPI::RoutesFromDefinition;
use Test;

my constant TEST_PORT = 30004;

my $api-doc = q:to/OPENAPI/;
    {
        "openapi": "3.0.0",
        "info": {
            "version": "1.0.0",
            "title": "Cro Test Case"
        },
        "paths": {
            "/pets/search": {
                "get": {
                    "summary": "Search for gets",
                    "operationId": "searchPets",
                    "parameters": [
                        {
                            "name": "type",
                            "in": "query",
                            "required": true,
                            "schema": {
                                "type": "string",
                                "enum": ["dog", "cat", "parrot"]
                            }
                        }
                    ]
                }
            }
        }
    }
    OPENAPI

my $application = openapi $api-doc, {
    operation 'searchPets', :allow-invalid, -> :$type {
        with request-validation-error() -> $error {
            content 'application/json', { :result('error'), :$type };
        }
        else {
            content 'application/json', { :result("ok"), :$type };
        }
    }
}

my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
$server.start;
my $uri = "http://127.0.0.1:{TEST_PORT}/pets/search";

{
    my $resp = await Cro::HTTP::Client.get: "$uri?type=dog";
    is $resp.status, 200, 'Valid request gets 200 response';
    is-deeply await($resp.body),
            { :result('ok'), :type('dog') },
            'Correct response body when validation successful';
}

{
    my $resp = await Cro::HTTP::Client.get: "$uri?type=monkey";
    is $resp.status, 200, 'Invalid request manually handled and gets 200 response';
    is-deeply await($resp.body),
            { :result('error'), :type('monkey') },
            'Correct response body when validation failed';
}

$server.stop;

done-testing;
