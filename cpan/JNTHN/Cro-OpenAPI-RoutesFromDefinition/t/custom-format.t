use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::OpenAPI::RoutesFromDefinition;
use Test;

my constant TEST_PORT = 30006;

my $api-doc = q:to/OPENAPI/;
    {
        "openapi": "3.0.0",
        "info": {
            "version": "1.0.0",
            "title": "Cro Test Case"
        },
        "paths": {
            "/format-test": {
                "get": {
                    "summary": "Test custom format validation",
                    "operationId": "tryFormat",
                    "parameters": [
                        {
                            "name": "var",
                            "in": "query",
                            "required": true,
                            "schema": {
                                "type": "string",
                                "format": "identifier"
                            }
                        }
                    ]
                }
            }
        }
    }
    OPENAPI

my %add-formats = identifier => /^<.ident>$/;
my $application = openapi $api-doc, :%add-formats, {
    operation 'tryFormat', -> :$var {
        content 'text/plain', "Var: $var";
    }
}

my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
$server.start;
my $uri = "http://127.0.0.1:{TEST_PORT}/format-test";

{
    my $resp = await Cro::HTTP::Client.get: "$uri?var=a123";
    is $resp.status, 200, 'Valid 200 response is returend when string matches custom format';
    is await($resp.body-text), 'Var: a123', 'String matching custom format accepted';
}

throws-like
    { await Cro::HTTP::Client.get: "$uri?var=123" },
    X::Cro::HTTP::Error,
    response => { .status == 400 },
    'When custom format not matched then 400 error';

$server.stop;

done-testing;
