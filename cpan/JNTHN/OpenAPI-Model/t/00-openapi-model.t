use v6.c;
use Test;
use OpenAPI::Model;
use JSON::Fast;

my $json-doc = q:to/END/;
{
    "openapi": "3.0.0",
    "info": {
        "title": "Sample Pet Store App",
        "termsOfService": "http://example.com/terms/",
        "version": "1.0.1",
        "contact": {
            "name": "API Support",
            "url": "http://www.example.com/support",
            "email": "support@example.com"
        },
        "license": {
            "name": "Apache 2.0",
            "url": "http://www.apache.org/licenses/LICENSE-2.0.html"
        }
    },
    "paths": {
        "/pets": {
            "get": {
                "description": "Returns all pets from the system that the user has access to",
                "responses": {
                    "200": {
                        "description": "A list of pets.",
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "array",
                                    "items": {
                                        "$ref": "#/components/schemas/pet"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    },
    "servers": [
        {
            "url": "https://development.gigantic-server.com/v1",
            "description": "Development server"
        },
        {
            "url": "https://staging.gigantic-server.com/v1",
            "description": "Staging server"
        },
        {
            "url": "https://{username}.gigantic-server.com:{port}/{basePath}",
            "description": "The production API server",
            "variables": {
                "username": {
                    "default": "demo",
                    "description": "this value is assigned by the service provider, in this example `gigantic-server.com`"
                },
                "port": {
                    "enum": [
                        "8443",
                        "443"
                    ],
                    "default": "8443"
                },
                "basePath": {
                    "default": "v2"
                }
            }
        }
    ]
}
END

my $api;

lives-ok { $api = OpenAPI::Model.from-json($json-doc, :!check-references) }, 'Can parse the document';

is $api.openapi, '3.0.0', 'openapi version is correct';

is $api.info.title, 'Sample Pet Store App', 'Info title is correct';
is $api.info.terms-of-service, 'http://example.com/terms/', 'Info terms of service url is correct';
is $api.info.version, '1.0.1', 'Info version is correct';

is $api.info.contact.name, 'API Support', 'Info Contact name is correct';
is $api.info.contact.url, 'http://www.example.com/support', 'Info Contact url is correct';
is $api.info.contact.email, 'support@example.com', 'Info Contact email is correct';

is $api.info.license.name, 'Apache 2.0', 'Info License name is correct';
is $api.info.license.url, 'http://www.apache.org/licenses/LICENSE-2.0.html', 'Info License url is correct';

is $api.servers.elems, 3, 'Correct number of servers';
is $api.servers[0].url, 'https://development.gigantic-server.com/v1', 'First server url is correct';
is $api.servers[1].description, 'Staging server', 'Second server description is correct';
is $api.servers[2].variables<username>.default, 'demo', 'username variable of third server is correct';
is $api.servers[2].variables<port>.enum[1], 443, 'port variable of third server is correct';

lives-ok { $api.servers[0].set-variable("song", OpenAPI::Model::Variable.new(default => "Parting", description => "Variable of song")) }, 'Can add variable for server';
is $api.servers[0].variables.elems, 1, 'Variable was added';
lives-ok { $api.servers[0].delete-variable("song") }, 'Can delete variable of server';

ok $api.paths.kv.elems == 2, 'Paths Object has correct number of elements from kv';
ok $api.paths</pets>:exists, 'EXISTS-KEY works';
my $path = $api.paths</pets>;
$api.paths.delete-path('/pets');
ok $api.paths.kv.elems == 0, 'Path was removed';
$api.paths.set-path('/pets', $path);
ok $api.paths.kv.elems == 2, 'Path was set for Paths object';
ok $api.paths.pairs ~~ Seq, 'paris methods returns Seq';
ok $api.paths.pairs.elems == 1, 'Paths Object has correct number of elements from pairs';
my $pair = $api.paths.pairs.first;
ok $pair ~~ Pair, 'Got correct pair from pairs';

is $api.serialize, from-json($json-doc), 'Serialization works';

done-testing;
