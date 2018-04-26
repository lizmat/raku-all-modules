use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::OpenAPI::RoutesFromDefinition;
use Test;

my constant TEST_PORT = 30002;

my $api-doc = q:to/OPENAPI/;
    {
        "openapi": "3.0.0",
        "info": {
            "version": "1.0.0",
            "title": "Cro Test Case"
        },
        "paths": {
            "/cookie-in": {
                "parameters": [
                    {
                        "name": "limit",
                        "in": "cookie",
                        "required": false,
                        "schema": {
                            "type": "integer"
                        }
                    }
                ],
                "get": {
                    "summary": "Test incoming cookie validation",
                    "operationId": "cookieIn",
                    "parameters": [
                        {
                            "name": "animal",
                            "in": "cookie",
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
    operation 'cookieIn', -> :$limit is cookie = '', :$animal is cookie = ''  {
        content 'text/plain', "Limit: $limit, Animal: $animal";
    }
}

my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
$server.start;
my $uri = "http://127.0.0.1:{TEST_PORT}";

{
    my $resp = await Cro::HTTP::Client.get: "$uri/cookie-in", cookies => {
        limit => 42,
        animal => 'cat'
    };
    is $resp.status, 200, 'Valid 200 response is returend when both cookies sent';
    is await($resp.body-text), 'Limit: 42, Animal: cat',
        'Got cookies in body as expected';
}

{
    my $resp = await Cro::HTTP::Client.get: "$uri/cookie-in", cookies => {
        animal => 'cat'
    };
    is $resp.status, 200, 'Valid 200 response is returend when only required cookie sent';
    is await($resp.body-text), 'Limit: , Animal: cat',
        'Got one required cookie in body as expected';
}

throws-like
    {
        await Cro::HTTP::Client.get: "$uri/cookie-in", cookies => {
            limit => 42
        }
    },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When missing required cookie, then 400 error';

throws-like
    {
        await Cro::HTTP::Client.get: "$uri/cookie-in", cookies => {
            animal => 'crab'
        }
    },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When required cookie does not match schema, then 400 error';

throws-like
    {
        await Cro::HTTP::Client.get: "$uri/cookie-in", cookies => {
            limit => 'none',
            animal => 'cat'
        }
    },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When optional cookie does not match schema, then 400 error';

$server.stop;

done-testing;
