use v6.c;
use Test;
use OpenAPI::Model :elements;
use JSON::Fast;

my $json = q:to/END/;
{
    "schema": {
        "$ref": "#/components/schemas/Pet"
    },
    "examples": {
        "cat": {
            "summary": "An example of a cat",
            "value": {
                "name": "Fluffy",
                "petType": "Cat",
                "color": "White",
                "gender": "male",
                "breed": "Persian"
            }
        },
        "dog": {
            "summary": "An example of a dog with a cat's name",
            "value": {
                "name": "Puma",
                "petType": "Dog",
                "color": "Black",
                "gender": "Female",
                "breed": "Mixed"
            }
        },
        "frog": {
            "$ref": "#/components/examples/frog-example"
        }
    }
}
END

my $api;

lives-ok { $api = MediaType.deserialize(from-json($json), OpenAPI::Model.new) }, 'Can parse media type with $ref';

is $api.serialize, from-json($json), 'Can serialize $ref';

done-testing;
