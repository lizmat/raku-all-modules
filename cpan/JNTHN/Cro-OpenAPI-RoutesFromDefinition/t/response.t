use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::OpenAPI::RoutesFromDefinition;
use Test;

my constant TEST_PORT = 29999;

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
                    "parameters": [
                        {
                            "name": "type",
                            "in": "query",
                            "required": true,
                            "schema": {
                                "type": "string"
                            }
                        }
                    ],
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
                        },
                        "409": {
                            "description": "OK response",
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "type": "object",
                                        "required": [
                                            "fields"
                                        ],
                                        "properties": {
                                            "fields": {
                                                "type": "array",
                                                "items": {
                                                    "type": "integer"
                                                }
                                            }
                                        }
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

my $application = openapi $api-doc, {
    operation 'makeResponse', -> :$type {
        given $type {
            when '200-good' {
                content 'application/json', {
                    name => 'Bob',
                    age => 42
                };
            }
            when '200-bad-content-type' {
                content 'text/plain', 'nope';
            }
            when '200-bad-schema' {
                content 'application/json', {
                    age => 42
                };
            }
            when '409-good' {
                conflict 'application/json', {
                    fields => [1,2]
                };
            }
            when '409-bad-content-type' {
                conflict 'text/plain', 'nope';
            }
            when '409-bad-schema' {
                conflict 'application/json', {
                    fields => ['foo',2]
                };
            }
            when '404' {
                not-found;
            }
            default {
                content 'application/json', {
                    name => 'Ooops',
                    age => 1
                };
            }
        }
    }
}

my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
$server.start;
my $uri = "http://127.0.0.1:{TEST_PORT}/test";

{
    my $resp = await Cro::HTTP::Client.get: "$uri?type=200-good";
    is $resp.status, 200, 'Valid 200 response is returend';
    is-deeply await($resp.body), { name => 'Bob', age => 42 },
            'Valid 200 response body as expected';
}

throws-like
    { await Cro::HTTP::Client.get: "$uri?type=409-good" },
    X::Cro::HTTP::Error,
    response => { .status == 409 && await(.body) eqv { fields => [1,2] } },
    'Valid 409 response sent as expected';

throws-like
    { await Cro::HTTP::Client.get: "$uri?type=404" },
    X::Cro::HTTP::Error,
    response => { .status == 500 },
    'Sending an unexpected response code leads to an internal server error';

throws-like
    { await Cro::HTTP::Client.get: "$uri?type=200-bad-content-type" },
    X::Cro::HTTP::Error,
    response => { .status == 500 },
    'Sending a 200 with a bad content type leads to an internal server error';

throws-like
    { await Cro::HTTP::Client.get: "$uri?type=200-bad-schema" },
    X::Cro::HTTP::Error,
    response => { .status == 500 },
    'Sending a 200 with a body not matching the schema leads to an internal server error';

throws-like
    { await Cro::HTTP::Client.get: "$uri?type=409-bad-content-type" },
    X::Cro::HTTP::Error,
    response => { .status == 500 },
    'Sending a 409 with a bad content type leads to an internal server error';

throws-like
    { await Cro::HTTP::Client.get: "$uri?type=409-bad-schema" },
    X::Cro::HTTP::Error,
    response => { .status == 500 },
    'Sending a 409 with a body not matching the schema leads to an internal server error';

done-testing;
