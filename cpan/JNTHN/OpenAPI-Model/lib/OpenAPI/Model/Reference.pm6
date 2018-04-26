use v6.c;

#| The OpenAPI::Model::Reference class represents an L<OpenAPI Reference object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#referenceObject>.
class OpenAPI::Model::Reference {
    has $.link is required;

    method serialize() {
        '$ref' => $!link
    }
}
