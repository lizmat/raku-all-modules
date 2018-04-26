use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::OpenAPI::RoutesFromDefinition;
use Test;

my constant TEST_PORT = 30003;

my $api-doc = q:to/OPENAPI/;
    {
        "openapi": "3.0.0",
        "info": {
            "version": "1.0.0",
            "title": "Cro Test Case"
        },
        "paths": {
            "/test": {
                "get": {
                    "summary": "Test response producer",
                    "operationId": "makeResponse",
                    "responses": {
                        "200": {
                            "description": "OK response",
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "$ref": "#/components/schemas/Person"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        },
        "components": {
            "schemas": {
                "Person": {
                    "type": "object",
                    "required": [
                        "name"
                    ],
                    "properties": {
                        "name": {
                            "type": "string"
                        },
                        "age": {
                            "type": "integer"
                        }
                    },
                    "additionalProperties": false
                }
            }
        }
    }
    OPENAPI

my $uri = "http://127.0.0.1:{TEST_PORT}/test";

{
    my $application = openapi $api-doc, {
        operation 'makeResponse', -> {
            content 'application/json', {
                age => 42
            };
        }
    }
    my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
    $server.start;
    throws-like
        { await Cro::HTTP::Client.get: $uri },
        X::Cro::HTTP::Error,
        response => { .status == 500 },
        'Sanity: by default, responses are validated and failure produces a 500';
    $server.stop;
}

{
    my $application = openapi $api-doc, :!validate-responses, {
        operation 'makeResponse', -> {
            content 'application/json', {
                age => 42
            };
        }
    }
    my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
    $server.start;
    my $resp = await Cro::HTTP::Client.get: $uri;
    is $resp.status, 200, 'Get 200 response when response validation disabled';
    is-deeply await($resp.body), { age => 42 },
        'Received invalid body OK';
    $server.stop;
}

done-testing;

