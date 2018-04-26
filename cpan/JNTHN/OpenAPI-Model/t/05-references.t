use v6.c;
use Test;
use JSON::Fast;
use OpenAPI::Model::Reference;
use OpenAPI::Model;

my $json-doc-begin = q:to/BEGIN/;
{
    "openapi": "3.0.0",
    "info": {
        "title": "Link Example",
        "version": "1.0.0"
    },
    "paths": {
        "/2.0/repositories/{username}": {
            "get": {
                "operationId": "getRepositoriesByOwner",
                "parameters": [
                    {
                        "name": "username",
                        "in": "path",
                        "required": true,
                        "schema": {
                            "type": "string"
                        }
                    }
                ],
                "responses": {
                    "200": {
                        "description": "repositories owned by the supplied user",
                        "content": {
                            "application/json": {
                                "schema": {
                                    "type": "array",
                                    "items": {
                                        "$ref": "#/components/schemas/repository"
                                    }
                                }
                            }
                        },
                        "links": {
BEGIN

my $json-doc-end = q:to/END/;
                        }
                    }
                }
            }
        }
    },
    "components": {
        "links": {
            "UserRepository": {
                "operationId": "getRepository",
                "parameters": {
                    "username": "$response.body#/owner/username",
                    "slug": "$response.body#/slug"
                }
            }
        },
        "schemas": {
            "repository": {
                "type": "object",
                "properties": {
                    "slug": {
                        "type": "string"
                    },
                    "owner": {
                        "$ref": "#/components/schemas/user"
                    }
                }
            },
            "user": {
                "type": "user"
            }
        }
    }
}
END

my $api;

my $json-doc = $json-doc-begin ~ q:to/MIDDLE/
                            "userRepository": {
                                "$ref": "#/components/links/UserRepository"
                            }
MIDDLE
~ $json-doc-end;

$api = OpenAPI::Model.from-json($json-doc, :!check-references);

is $api.serialize, from-json($json-doc), 'Serialization works';

my $link1 = $api.paths</2.0/repositories/{username}>.get.responses<200>.links<userRepository>;
my $link2 = $api.paths</2.0/repositories/{username}>.get.responses<200>.get-link('userRepository');

my $ref = $api.paths</2.0/repositories/{username}>.get.responses<200>.raw-get-link('userRepository');

ok $link1 !~~ OpenAPI::Model::Reference, 'AT-KEY gives resolved link';
ok $link2 !~~ OpenAPI::Model::Reference, 'get-link gives resolved link';
ok $ref    ~~ OpenAPI::Model::Reference, 'raw-get-link gives Reference object';

is $link1.operation-id, 'getRepository', 'Link is resolved into object correctly';
is $ref.link, '#/components/links/UserRepository', 'Link is parsed properly';

$json-doc = $json-doc-begin ~ q:to/MIDDLE/
                            "userRepository": {
                                "$ref": "#/components/links/UserRepository"
                            },
                            "doesntExist1": {
                                "$ref": "#/components/badLink"
                            },
                            "doesntExist2": {
                                "$ref": "#/components/links/BadKey"
                            }
MIDDLE
~ $json-doc-end;


lives-ok { $api = OpenAPI::Model.from-json($json-doc, :!check-references) }, 'Can parse bad schema when check is disabled';

is $api.serialize, from-json($json-doc), 'Serialization works';

dies-ok { $api.paths</2.0/repositories/{username}>.get.responses<200>.links<doesntExist1> },
  'Dies on attempt to resolve incorrect reference';

dies-ok { $api.paths</2.0/repositories/{username}>.get.responses<200>.links<doesntExist2> },
  'Dies on attempt to resolve incorrect reference on hash';

$json-doc = $json-doc-begin ~ q:to/MIDDLE/
                            "external": {
                                "$ref": "external.json#/components/links/UserRepository"
                            }
MIDDLE
~ $json-doc-end;

lives-ok { $api = OpenAPI::Model.from-json($json-doc, :!check-references) }, 'Can parse schema with external refs';

dies-ok { $api.paths</2.0/repositories/{username}>.get.responses<200>.links<external> },
  'Dies on attempt to resolve external link without matching model';

my $external-json-doc = $json-doc-begin ~ $json-doc-end;
my $external-api = OpenAPI::Model.from-json($external-json-doc, :!check-references);

lives-ok { $api = OpenAPI::Model.from-json($json-doc, external => {'external.json' => $external-api}, :!check-references)  },
  'Can parse schema with external refs';

my $ext-link = $api.paths</2.0/repositories/{username}>.get.responses<200>.links<external>;
ok $ext-link ~~ OpenAPI::Model::Link, 'Link is resolved';
is $ext-link.operation-id, 'getRepository', 'Link is correct';

is $api.paths</2.0/repositories/{username}>.get.responses<200>.content<application/json>.schema<type>, 'array', 'Resolved first level';
is $api.paths</2.0/repositories/{username}>.get.responses<200>.content<application/json>.schema<items><properties><owner><type>, 'user', 'Resolved third level';

done-testing;
