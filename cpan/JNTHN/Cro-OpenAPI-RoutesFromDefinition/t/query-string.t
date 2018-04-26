use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::OpenAPI::RoutesFromDefinition;
use Test;

my constant TEST_PORT = 29998;

my $api-doc = q:to/OPENAPI/;
    {
        "openapi": "3.0.0",
        "info": {
            "version": "1.0.0",
            "title": "Cro Test Case"
        },
        "paths": {
            "/pets/search": {
                "parameters": [
                    {
                        "name": "limit",
                        "in": "query",
                        "required": false,
                        "schema": {
                            "type": "integer"
                        }
                    }
                ],
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
        },
        "components": {
            "schemas": {
                "Pet": {
                    "type": "object",
                    "required": [
                        "id",
                        "name"
                    ],
                    "properties": {
                        "id": {
                            "type": "integer",
                            "format": "int64"
                        },
                        "name": {
                            "type": "string"
                        },
                        "tag": {
                            "type": "string"
                        }
                    },
                    "additionalProperties": false
                }
            }
        }
    }
    OPENAPI

throws-like
    {
        openapi $api-doc, {
            operation 'searchPets', -> :$type, :$no-such, :$limit {
            }
        }
    },
    X::Cro::OpenAPI::RoutesFromDefinition::UnexpectedQueryPrameter,
    operation => 'searchPets',
    parameter => 'no-such';

my $application = openapi $api-doc, {
    operation 'searchPets', -> :$type, :$limit = -1 {
        content 'text/plain', "$type, $limit";
    }
}

my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
$server.start;
my $uri = "http://127.0.0.1:{TEST_PORT}/pets/search";

{
    my $resp = await Cro::HTTP::Client.get: "$uri?type=dog&limit=42";
    is $resp.status, 200, 'Valid request with both query string params gets 200 response';
    is await($resp.body-text), "dog, 42", 'Valid request with both query string params got params';
}

{
    my $resp = await Cro::HTTP::Client.get: "$uri?type=dog";
    is $resp.status, 200, 'Valid request with required query string param gets 200 response';
    is await($resp.body-text), "dog, -1", 'Valid request with one query string param got param';
}

throws-like
    {
        await Cro::HTTP::Client.get: "$uri?limit=42"
    },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When missing required query string parameter, then 400 error';

throws-like
    {
        await Cro::HTTP::Client.get: "$uri?type=dog&no-such=param"
    },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When unexpected query string parameter, then 400 error';

throws-like
    {
        await Cro::HTTP::Client.get: "$uri?type=lolcat"
    },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When schema does not match, then 400 error (1)';

throws-like
    {
        await Cro::HTTP::Client.get: "$uri?type=dog&limit=none"
    },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When schema does not match, then 400 error (2)';

$server.stop;

done-testing;
