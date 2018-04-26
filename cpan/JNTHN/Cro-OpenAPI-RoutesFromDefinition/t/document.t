use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::OpenAPI::RoutesFromDefinition;
use JSON::Fast;
use Test;
use YAMLish;

my constant TEST_PORT = 30007;

my $api-doc = q:to/OPENAPI/;
    {
        "openapi": "3.0.0",
        "info": {
            "version": "1.0.0",
            "title": "Cro Test Case"
        },
        "paths": {
            "/header-in": {
                "parameters": [
                    {
                        "name": "X-Limit",
                        "in": "header",
                        "required": false,
                        "schema": {
                            "type": "integer"
                        }
                    }
                ],
                "get": {
                    "summary": "Test incoming header validation",
                    "operationId": "headerIn",
                    "parameters": [
                        {
                            "name": "X-Animal",
                            "in": "header",
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

subtest 'Default OpenAPI document serving' => {
    my $application = openapi $api-doc, {
        operation 'headerIn', -> {
            content 'text/plain', 'ok';
        }
    }
    my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
    $server.start;
    my $uri = "http://127.0.0.1:{TEST_PORT}";

    {
        my $resp = await Cro::HTTP::Client.get: "$uri/openapi.json";
        is $resp.status, 200, 'Valid 200 response for /openapi.json';
        is $resp.content-type.type-and-subtype, 'application/json',
            'Response has JSON content type';
        lives-ok { from-json await($resp.body-text) },
            'Response parses as a JSON document';
    }

    {
        my $resp = await Cro::HTTP::Client.get: "$uri/openapi.yaml";
        is $resp.status, 200, 'Valid 200 response for /openapi.yaml';
        is $resp.content-type.type-and-subtype, 'application/x-yaml',
            'Response has YAML content type';
        lives-ok { load-yaml await($resp.body-text) },
            'Response parses as a YAML document';
    }

    $server.stop;
}

subtest 'Custom OpenAPI document serving' => {
    my $application = openapi $api-doc, :document{ '/' => 'json' }, {
        operation 'headerIn', -> {
            content 'text/plain', 'ok';
        }
    }
    my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
    $server.start;
    my $uri = "http://127.0.0.1:{TEST_PORT}";

    {
        my $resp = await Cro::HTTP::Client.get: "$uri/";
        is $resp.status, 200, 'Valid 200 response for /';
        is $resp.content-type.type-and-subtype, 'application/json',
            'Response has JSON content type';
        lives-ok { from-json await($resp.body-text) },
            'Response parses as a JSON document';
    }

    throws-like
        { await Cro::HTTP::Client.get: "$uri/openapi.json" },
        X::Cro::HTTP::Error,
        response => { .status == 404 },
        'With custom document configuration, do not serve default JSON';
    throws-like
        { await Cro::HTTP::Client.get: "$uri/openapi.yaml" },
        X::Cro::HTTP::Error,
        response => { .status == 404 },
        'With custom document configuration, do not serve default YAML';

    $server.stop;
}

done-testing;
