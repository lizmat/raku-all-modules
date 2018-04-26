use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::OpenAPI::RoutesFromDefinition;
use Test;

my constant TEST_PORT = 30000;

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
            },
            "/header-out": {
                "get": {
                    "summary": "Test outgoing header validation",
                    "operationId": "headerOut",
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
                            "headers": {
                                "X-Remaining": {
                                    "required": true,
                                    "schema": {
                                        "type": "integer"
                                    }
                                },
                                "X-FreeRemaining": {
                                    "required": false,
                                    "schema": {
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
    OPENAPI

my $application = openapi $api-doc, {
    operation 'headerIn', -> :$X-Limit is header = '', :$X-Animal is header = ''  {
        content 'text/plain', "Limit: $X-Limit, Animal: $X-Animal";
    }
    operation 'headerOut', -> :$type {
        given $type {
            when 'both' {
                header 'X-Remaining', 100;
                header 'X-FreeRemaining', 5;
            }
            when 'required' {
                header 'X-Remaining', 100;
            }
            when 'missing' {
                header 'X-FreeRemaining', 5;
            }
            when 'bad-required' {
                header 'X-Remaining', 'nope';
                header 'X-FreeRemaining', 5;
            }
            when 'bad-optional' {
                header 'X-Remaining', 100;
                header 'X-FreeRemaining', 'nope';
            }
        }
        content 'text/plain', 'ok';
    }
}

my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
$server.start;
my $uri = "http://127.0.0.1:{TEST_PORT}";

{
    my $resp = await Cro::HTTP::Client.get: "$uri/header-in", headers => {
        X-Limit => 42,
        X-Animal => 'cat'
    };
    is $resp.status, 200, 'Valid 200 response is returend when both headers sent';
    is await($resp.body-text), 'Limit: 42, Animal: cat',
        'Got headers in body as expected';
}

{
    my $resp = await Cro::HTTP::Client.get: "$uri/header-in", headers => {
        X-Animal => 'cat'
    };
    is $resp.status, 200, 'Valid 200 response is returend when only required header sent';
    is await($resp.body-text), 'Limit: , Animal: cat',
        'Got one required header in body as expected';
}

throws-like
    {
        await Cro::HTTP::Client.get: "$uri/header-in", headers => {
            X-Limit => 42
        }
    },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When missing required header, then 400 error';

throws-like
    {
        await Cro::HTTP::Client.get: "$uri/header-in", headers => {
            X-Animal => 'crab'
        }
    },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When required header does not match schema, then 400 error';

throws-like
    {
        await Cro::HTTP::Client.get: "$uri/header-in", headers => {
            X-Limit => "no no, no no there's no limit",
            X-Animal => 'cat'
        }
    },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When optional header does not match schema, then 400 error';

{
    my $resp = await Cro::HTTP::Client.get: "$uri/header-out?type=both";
    is $resp.status, 200, 'Valid 200 response is returend when response has both headers';
    is $resp.header('X-Remaining'), 100, 'Correct value of requied header';
    is $resp.header('X-FreeRemaining'), 5, 'Correct value of optional header';
}

{
    my $resp = await Cro::HTTP::Client.get: "$uri/header-out?type=required";
    is $resp.status, 200, 'Valid 200 response is returend when response has required header';
    is $resp.header('X-Remaining'), 100, 'Correct value of requied header';
    nok defined($resp.header('X-FreeRemaining')), 'No optional header';
}

throws-like
    { await Cro::HTTP::Client.get: "$uri/header-out?type=missing" },
    X::Cro::HTTP::Error,
    response => { .status == 500 },
    'Sending a response missing required headers results in a 500 error';

throws-like
    { await Cro::HTTP::Client.get: "$uri/header-out?type=bad-required" },
    X::Cro::HTTP::Error,
    response => { .status == 500 },
    'Sending a response with a required header not matching schema results in a 500 error';

throws-like
    { await Cro::HTTP::Client.get: "$uri/header-out?type=bad-optional" },
    X::Cro::HTTP::Error,
    response => { .status == 500 },
    'Sending a response with an optional header not matching schema results in a 500 error';

$server.stop;

done-testing;
