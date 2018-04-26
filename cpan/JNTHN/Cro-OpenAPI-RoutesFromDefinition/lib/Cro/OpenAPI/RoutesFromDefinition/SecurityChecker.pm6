use Cro::HTTP::Request;
use OpenAPI::Model;

role Cro::OpenAPI::RoutesFromDefinition::SecurityChecker {
    method is-allowed(OpenAPI::Model::SecurityScheme $scheme, Cro::HTTP::Request $request,
            @requirements, :$operation-id --> Bool) { ... }

    method get-api-key(OpenAPI::Model::SecurityScheme $scheme, Cro::HTTP::Request $request --> Str) {
        fail "Type type of scheme is not apiKey" unless $scheme.type eq 'apiKey';
        my $name = $scheme.name;
        given $scheme.in {
            when 'cookie' {
                with $request.cookie-value($name) {
                    .return;
                }
                else {
                    fail "Request is missing apiKey cookie '$name'";
                }
            }
            when 'header' {
                with $request.header($name) {
                    .return;
                }
                else {
                    fail "Request is missing apiKey header '$name'";
                }
            }
            when 'query' {
                with $request.query-value($name) {
                    .return;
                }
                else {
                    fail "Request is missing apiKey query string argument '$name'";
                }
            }
            default {
                fail "Unknown apiKey source '$_'";
            }
        }
    }
}
