use Cro::HTTP::Client;
use Cro::HTTP::Router;
use Cro::HTTP::Server;
use Cro::OpenAPI::RoutesFromDefinition;
use Test;

my constant TEST_PORT = 29996;

my $pet-store = q:to/OPENAPI/;
    {
        "openapi": "3.0.0",
        "info": {
            "version": "1.0.0",
            "title": "Swagger Petstore",
            "license": {
                "name": "MIT"
            }
        },
        "servers": [
            {
                "url": "http://petstore.swagger.io/v1"
            }
        ],
        "paths": {
            "/pets": {
                "get": {
                    "summary": "List all pets",
                    "operationId": "listPets",
                    "tags": [
                        "pets"
                    ],
                    "parameters": [
                        {
                            "name": "limit",
                            "in": "query",
                            "description": "How many items to return at one time (max 100)",
                            "required": false,
                            "schema": {
                                "type": "integer",
                                "format": "int32"
                            }
                        }
                    ],
                    "responses": {
                        "200": {
                            "description": "An paged array of pets",
                            "headers": {
                                "x-next": {
                                    "description": "A link to the next page of responses",
                                    "schema": {
                                        "type": "string"
                                    }
                                }
                            },
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "$ref": "#/components/schemas/Pets"
                                    }
                                }
                            }
                        },
                        "default": {
                            "description": "unexpected error",
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "$ref": "#/components/schemas/Error"
                                    }
                                }
                            }
                        }
                    }
                },
                "post": {
                    "summary": "Create a pet",
                    "operationId": "createPets",
                    "tags": [
                        "pets"
                    ],
                    "responses": {
                        "201": {
                            "description": "Null response"
                        },
                        "default": {
                            "description": "unexpected error",
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "$ref": "#/components/schemas/Error"
                                    }
                                }
                            }
                        }
                    }
                }
            },
            "/pets/{petId}": {
                "get": {
                    "summary": "Info for a specific pet",
                    "operationId": "showPetById",
                    "tags": [
                        "pets"
                    ],
                    "parameters": [
                        {
                            "name": "petId",
                            "in": "path",
                            "required": true,
                            "description": "The id of the pet to retrieve",
                            "schema": {
                                "type": "string"
                            }
                        }
                    ],
                    "responses": {
                        "200": {
                            "description": "Expected response to a valid request",
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "$ref": "#/components/schemas/Pets"
                                    }
                                }
                            }
                        },
                        "default": {
                            "description": "unexpected error",
                            "content": {
                                "application/json": {
                                    "schema": {
                                        "$ref": "#/components/schemas/Error"
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
                "Pet": {
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
                    }
                },
                "Pets": {
                    "type": "array",
                    "items": {
                        "$ref": "#/components/schemas/Pet"
                    }
                },
                "Error": {
                    "required": [
                        "code",
                        "message"
                    ],
                    "properties": {
                        "code": {
                            "type": "integer",
                            "format": "int32"
                        },
                        "message": {
                            "type": "string"
                        }
                    }
                }
            }
        }
    }
    OPENAPI

throws-like
    {
        openapi $pet-store, {
            get -> 'foo' {
            }
        };
    },
    X::Cro::OpenAPI::RoutesFromDefinition::InvalidUse,
    what => 'get';

throws-like
    {
        openapi $pet-store, {
            post -> 'foo' {
            }
        };
    },
    X::Cro::OpenAPI::RoutesFromDefinition::InvalidUse,
    what => 'post';

throws-like
    {
        openapi $pet-store, {
            include route { get -> { } }
        };
    },
    X::Cro::OpenAPI::RoutesFromDefinition::InvalidUse,
    what => 'include';

throws-like
    {
        openapi $pet-store, {
            delegate 'foo' => route { get -> { } }
        };
    },
    X::Cro::OpenAPI::RoutesFromDefinition::InvalidUse,
    what => 'delegate';

lives-ok
    {
        openapi $pet-store, :ignore-unimplemented, {
            ;
        }
    },
    'With :ignore-unimplemented, no error even if no operations implemented';

throws-like
    {
        openapi $pet-store, {
            ;
        }
    },
    X::Cro::OpenAPI::RoutesFromDefinition::UnimplementedOperations,
    operations => [<createPets listPets showPetById>];

lives-ok
    {
        openapi $pet-store, {
            operation 'listPets', -> {
            }
            operation 'createPets', -> {
            }
            operation 'showPetById', -> $id {
            }
        }
    },
    'Valid opperation declarations are accepted';

throws-like
    {
        openapi $pet-store, {
            operation 'listPets', -> {
            }
            operation 'createPets', -> {
            }
            operation 'surprise', -> {
            }
            operation 'showPetById', -> $id {
            }
        }
    },
    X::Cro::OpenAPI::RoutesFromDefinition::UnspecifiedOperation,
    operation => 'surprise';

throws-like
    {
        openapi $pet-store, {
            operation 'listPets', -> {
            }
            operation 'createPets', -> {
            }
            operation 'showPetById', -> {
            }
        }
    },
    X::Cro::OpenAPI::RoutesFromDefinition::WrongPathSegmentCount,
    operation => 'showPetById',
    path-template => '/pets/{petId}',
    expected => 1,
    got => 0;

subtest 'Basic operation handler invocation' => {
    my $application = openapi $pet-store, {
        operation 'listPets', -> {
            not-found 'application/json', {
                code => 42,
                message => 'listPets NYI'
            };
        }
        operation 'createPets', -> {
            not-found 'application/json', {
                code => 42,
                message => 'createPets NYI'
            };
        }
        operation 'showPetById', -> $id {
            not-found 'application/json', {
                code => 42,
                message => "showPetById($id) NYI";
            };
        }
    }
    my $server = Cro::HTTP::Server.new: :host<0.0.0.0>, :port(TEST_PORT), :$application;
    $server.start;
    LEAVE $server.stop;

    sub get-error-json($path, $method, $body?) {
        await Cro::HTTP::Client."$method"(
            "http://127.0.0.1:{TEST_PORT}$path",
            |($body ?? { :content-type('application/json'), :$body } !! Empty));
        CATCH {
            when X::Cro::HTTP::Error {
                return await .response.body;
            }
        }
        return "WRONG";
    }

    is-deeply get-error-json("/pets", "get"),
        { code => 42, message => 'listPets NYI' },
        'Can call listPets operation';
    is-deeply get-error-json("/pets", "post", { :id(123), :name('Dave') }),
        { code => 42, message => 'createPets NYI' },
        'Can call createPets operation';
    is-deeply get-error-json("/pets/101", "get"),
        { code => 42, message => 'showPetById(101) NYI' },
        'Can call showPetById operation';
}

done-testing;
