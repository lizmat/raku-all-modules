use OpenAPI::Model::OpenAPI;
use JSON::Fast;
use YAMLish;

class OpenAPI::Model {
    has $.root;
    has $.check-references;
    has %.external;

    my package EXPORT::elements {
        constant Callback = OpenAPI::Model::Callback;
        constant Components = OpenAPI::Model::Components;
        constant Contact = OpenAPI::Model::Contact;
        constant Discriminator = OpenAPI::Model::Discriminator;
        constant Encoding = OpenAPI::Model::Encoding;
        constant Example = OpenAPI::Model::Example;
        constant ExternalDocs = OpenAPI::Model::ExternalDocs;
        constant Header = OpenAPI::Model::Header;
        constant Info = OpenAPI::Model::Info;
        constant License = OpenAPI::Model::License;
        constant Link = OpenAPI::Model::Link;
        constant MediaType = OpenAPI::Model::MediaType;
        constant OAuthFlow = OpenAPI::Model::OAuthFlow;
        constant OAuthFlows = OpenAPI::Model::OAuthFlows;
        constant Operation = OpenAPI::Model::Operation;
        constant Parameter = OpenAPI::Model::Parameter;
        constant Path = OpenAPI::Model::Path;
        constant Paths = OpenAPI::Model::Paths;
        constant RequestBody = OpenAPI::Model::RequestBody;
        constant Response = OpenAPI::Model::Response;
        constant Responses = OpenAPI::Model::Responses;
        constant Schema = OpenAPI::Model::Schema;
        constant Security = OpenAPI::Model::Security;
        constant SecurityScheme = OpenAPI::Model::SecurityScheme;
        constant Server = OpenAPI::Model::Server;
        constant Tag = OpenAPI::Model::Tag;
        constant Variable = OpenAPI::Model::Variable;
    }

    method !from-source($source, :%external, :$check-references) {
        die X::OpenAPI::Model::InvalidFormat.new if $source ~~ Failure;
        my $model = self.new(:%external, :$check-references);
        my $root = OpenAPI::Model::OpenAPI.deserialize($source, $model);
        $model!set-root($root);
        $root.reference-check() if $check-references;
        $root;
    }

    method !set-root($root) { $!root = $root }

    method from-yaml($yaml, :%external, :$check-references = True) {
        self!from-source((load-yaml $yaml), :%external, :$check-references);
    }
    method from-json($json, :%external, :$check-references = True) {
        self!from-source((from-json $json), :%external, :$check-references);
    }
}
