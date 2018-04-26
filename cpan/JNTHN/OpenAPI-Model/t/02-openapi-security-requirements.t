use v6.c;
use Test;
use JSON::Fast;
use OpenAPI::Model;

my $json1 = q:to/END/;
{
    "api_key": []
}
END

my $json2 = q:to/END/;
{
    "petstore_auth": [
        "write:pets",
        "read:pets"
    ]
}
END

my $api;

lives-ok { $api = OpenAPI::Model::Security.deserialize((from-json $json1), OpenAPI::Model.new) }, 'Can parse empty rule';

ok $api<api_key> == [], 'First schema is parsed';

lives-ok { $api = OpenAPI::Model::Security.deserialize((from-json $json2), OpenAPI::Model.new) }, 'Can parse non-empty rule';

ok $api<petstore_auth> eqv ["write:pets", "read:pets"], 'Second schema is parsed';

my $json3 = q:to/END/;
{
    "type": "apiKey",
    "name": "api_key",
    "in": "header",
    "scheme": "oauth2",
    "flows": {
        "implicit": {
            "authorizationUrl": "https://example.com/api/oauth/dialog",
            "tokenUrl": "https://example.com/api/oauth/token",
            "scopes": {
                "write:pets": "modify pets in your account",
                "read:pets": "read your pets"
            }
        }
    },
    "openIdConnectUrl": "http://example.com"
}
END

lives-ok { $api = OpenAPI::Model::SecurityScheme.deserialize((from-json $json3), OpenAPI::Model.new) }, 'Security Scheme is parsed';

done-testing;
