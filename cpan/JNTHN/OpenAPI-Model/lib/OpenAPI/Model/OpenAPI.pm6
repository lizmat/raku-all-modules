use v6.c;

use OpenAPI::Model::Element;
use OpenAPI::Model::PatternedObject;
use OpenAPI::Model::Reference;

class OpenAPI::Model::Callback {...}
class OpenAPI::Model::Components {...}
class OpenAPI::Model::Contact {...}
class OpenAPI::Model::Discriminator {...}
class OpenAPI::Model::Encoding {...}
class OpenAPI::Model::Example {...}
class OpenAPI::Model::ExternalDocs {...}
class OpenAPI::Model::Header {...}
class OpenAPI::Model::Info {...}
class OpenAPI::Model::License {...}
class OpenAPI::Model::Link {...}
class OpenAPI::Model::MediaType {...}
class OpenAPI::Model::OAuthFlow {...}
class OpenAPI::Model::OAuthFlows {...}
class OpenAPI::Model::Operation {...}
class OpenAPI::Model::Parameter {...}
class OpenAPI::Model::Path {...}
class OpenAPI::Model::Paths {...}
class OpenAPI::Model::RequestBody {...}
class OpenAPI::Model::Response {...}
class OpenAPI::Model::Responses {...}
class OpenAPI::Model::Schema {...}
class OpenAPI::Model::Security {...}
class OpenAPI::Model::SecurityScheme {...}
class OpenAPI::Model::Server {...}
class OpenAPI::Model::Tag {...}
class OpenAPI::Model::Variable {...}

# Subsets with references
subset RefSchema where OpenAPI::Model::Schema|OpenAPI::Model::Reference;
subset RefExample where OpenAPI::Model::Example|OpenAPI::Model::Reference;
subset RefResponse where OpenAPI::Model::Response|OpenAPI::Model::Reference;
subset RefParameter where OpenAPI::Model::Parameter|OpenAPI::Model::Reference;
subset RefRequestBody where OpenAPI::Model::RequestBody|OpenAPI::Model::Reference;
subset RefHeader where OpenAPI::Model::Header|OpenAPI::Model::Reference;
subset RefSecurityScheme where OpenAPI::Model::SecurityScheme|OpenAPI::Model::Reference;
subset RefLink where OpenAPI::Model::Link|OpenAPI::Model::Reference;
subset RefCallback where OpenAPI::Model::Callback|OpenAPI::Model::Reference;

class X::OpenAPI::Model::InvalidFormat is Exception {
    method message() {
        "Attempt to parse the document failed due to invalid format."
    }
}

#| The OpenAPI::Model::Components class represents an L<OpenAPI Components object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#componentsObject>.
class OpenAPI::Model::Components does OpenAPI::Model::Element[
    scalar => {},
    object => {
        schemas => {
            hash => True,
            ref => True,
            raw => True,
            type => OpenAPI::Model::Schema
        },
        responses => {
            hash => True,
            ref => True,
            type => OpenAPI::Model::Response
        },
        parameters => {
            hash => True,
            ref => True,
            type => OpenAPI::Model::Parameter
        },
        examples => {
            hash => True,
            ref => True,
            type => OpenAPI::Model::Example
        },
        requestBodies => {
            attr => 'request-bodies',
            hash => True,
            ref => True,
            type => OpenAPI::Model::RequestBody
        },
        headers => {
            hash => True,
            ref => True,
            type => OpenAPI::Model::Header
        },
        securitySchemes => {
            attr => 'security-schemes',
            hash => True,
            ref => True,
            type => OpenAPI::Model::SecurityScheme
        },
        links => {
            hash => True,
            ref => True,
            type => OpenAPI::Model::Link
        },
        callbacks => {
            hash => True,
            ref => True,
            type => OpenAPI::Model::Callback
        }
    }] {
    #| Represents a hash that holds reusable Schema Objects.
    has RefSchema %.schemas;
    #| Represents a hash that holds reusable Response Objects.
    has RefResponse %.responses;
    #| Represents a hash that holds reusable Parameter Objects.
    has RefParameter %.parameters;
    #| Represents a hash that holds reusable Example Objects.
    has RefExample %.examples;
    #| Represents a hash that holds reusable Request Body Objects.
    has RefRequestBody %.request-bodies;
    #| Represents a hash that holds reusable Header Objects.
    has RefHeader %.headers;
    #| Represents a hash that holds reusable Security Scheme Objects.
    has RefSecurityScheme %.security-schemes;
    #| Represents a hash that holds reusable Link Objects.
    has RefLink %.links;
    #| Represents a hash that holds reusable Callback Objects.
    has RefCallback %.callbacks;

    # Getters
    #| Returns a hash that holds reusable Schema Objects.
    method schemas() { %!schemas.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Schema) }).Hash }
    method raw-schemas() { %!schemas }
    #| Returns a hash that holds reusable Response Objects.
    method responses() { %!responses.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Response) }).Hash }
    method raw-responses() { %!responses }
    #| Returns a hash that holds reusable Parameter Objects.
    method parameters() { %!parameters.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Parameter) }).Hash }
    method raw-parameters() { %!parameters }
    #| Returns a hash that holds reusable Example Objects.
    method examples()  { %!examples.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Example) }).Hash }
    method raw-examples() { %!examples }
    #| Returns a hash that holds reusable Request Body Objects.
    method request-bodies() { %!request-bodies.map({ .key => self!resolve(.value, expect => OpenAPI::Model::RequestBody) }).Hash }
    method raw-request-bodies() { %!request-bodies }
    #| Returns a hash that holds reusable Header Objects.
    method headers() { %!headers.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Header) }).Hash }
    method raw-headers() { %!headers }
    #| Returns a hash that holds reusable Security Scheme Objects.
    method security-schemes() { %!security-schemes.map({ .key => self!resolve(.value, expect => OpenAPI::Model::SecurityScheme) }).Hash }
    method raw-security-schemes() { %!security-schemes }
    #| Returns a hash that holds reusable Link Objects.
    method links() { %!links.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Link) }).Hash }
    method raw-links() { %!links }
    #| Returns a hash that holds reusable Callback Objects.
    method callbacks() { %!callbacks.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Callback) }).Hash }
    method raw-callbacks() { %!callbacks }

    # Object getters
    method get-schema(Str $id) { self!resolve(%!schemas{$id}, expect => OpenAPI::Model::Schema) }
    method get-raw-schema(Str $id) { %!schemas{$id} }
    method get-response(Str $id) { self!resolve(%!responses{$id}, expect => OpenAPI::Model::Response) }
    method get-raw-response(Str $id) { %!responses{$id} }
    method get-parameter(Str $id) { self!resolve(%!parameters{$id}, expect => OpenAPI::Model::Parameter) }
    method get-raw-parameter(Str $id) { %!parameters{$id} }
    method get-example(Str $id) { self!resolve(%!examples{$id}, expect => OpenAPI::Model::Example) }
    method get-raw-example(Str $id) { %!examples{$id} }
    method get-request-body(Str $id) { self!resolve(%!request-bodies{$id}, expect => OpenAPI::Model::RequestBody) }
    method get-raw-request-body(Str $id) { %!request-bodies{$id} }
    method get-header(Str $id) { self!resolve(%!headers{$id}, expect => OpenAPI::Model::Header) }
    method get-raw-header(Str $id) { %!headers{$id} }
    method get-security-scheme(Str $id) { self!resolve(%!security-schemes{$id}, expect => OpenAPI::Model::SecurityScheme) }
    method get-raw-security-scheme(Str $id) { %!security-schemes{$id} }
    method get-link(Str $id) { self!resolve(%!links{$id}, expect => OpenAPI::Model::Link) }
    method get-raw-link(Str $id) { %!links{$id} }
    method get-callback(Str $id) { self!resolve(%!callbacks{$id}), expect => OpenAPI::Model::Callback }
    method get-raw-callback(Str $id) { %!callbacks{$id} }

    # Setters
    #| Adds schema into components by id.
    method set-schema(Str $id, RefSchema:D $schema --> Nil) { %!schemas{$id} = $schema }
    #| Deletes schema from components by id.
    method delete-schema(Str $id) { %!schemas{$id}:delete }
    #| Adds response into components by id.
    method set-response(Str $id, RefResponse:D $response --> Nil) { %!responses{$id} = $response }
    #| Deletes response from components by id.
    method delete-response(Str $id) { %!responses{$id}:delete }
    #| Adds parameter into components by id.
    method set-parameter(Str $id, RefParameter:D $parameter --> Nil) { %!parameters{$id} = $parameter }
    #| Deletes parameter from components by id.
    method delete-parameter(Str $id) { %!parameters{$id}:delete }
    #| Adds example into components by id.
    method set-example(Str $id, RefExample:D $example --> Nil) { %!examples{$id} = $example }
    #| Deletes example from components by id.
    method delete-example(Str $id) { %!examples{$id}:delete }
    #| Adds Response Body into components by id.
    method set-request-body(Str $id, RefRequestBody:D $body --> Nil) { %!request-bodies{$id} = $body }
    #| Deletes Response Body from components by id.
    method delete-request-body(Str $id) { %!request-bodies{$id}:delete }
    #| Adds header into components by id.
    method set-header(Str $id, RefHeader:D $header --> Nil) { %!headers{$id} = $header }
    #| Deletes header from components by id.
    method delete-header(Str $id) { %!headers{$id}:delete }
    #| Adds Security Scheme into components by id.
    method set-security-scheme(Str $id, RefSecurityScheme:D $scheme --> Nil) { %!security-schemes{$id} = $scheme }
    #| Deletes Security Scheme from components by id.
    method delete-security-scheme(Str $id) { %!security-schemes{$id}:delete }
    #| Adds link into components by id.
    method set-link(Str $id, RefLink:D $link --> Nil) { %!links{$id} = $link }
    #| Deletes link from components by id.
    method delete-link(Str $id) { %!links{$id}:delete }
    #| Adds callback into components by id.
    method set-callback(Str $id, RefCallback:D $callback --> Nil) { %!callbacks{$id} = $callback }
    #| Deletes callback from components by id.
    method delete-callback(Str $id) { %!callbacks{$id}:delete }
}

#| The OpenAPI::Model::Callback class represents an L<OpenAPI Callback object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#callbackObject>.
class OpenAPI::Model::Callback does OpenAPI::Model::PatternedObject does OpenAPI::Model::Element[
    scalar => {},
    object => {},
    :patterned(OpenAPI::Model::Path)] {
    method serialize() { self.OpenAPI::Model::PatternedObject::serialize() }

    #| Adds path to callback by id.
    method set-path(Str $id, OpenAPI::Model::Path $path) { %!container{$id} = $path }
    #| Deletes path from callback by id.
    method delete-path(Str $id) { %!container{$id}:delete }
    #| Returns OpenAPI::Model::Path object by id.
    method get-path(Str $id) { %!container{$id} }
}

#| The OpenAPI::Model::Contact class represents an L<OpenAPI Contact object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#contactObject>.
class OpenAPI::Model::Contact does OpenAPI::Model::Element[
    scalar => {
        name => {},
        url => {},
        email => {}
    }] {
    #| Represents a name of the contact person/organization.
    has Str $.name is rw;
    #| Represents a URL pointing to the contact information.
    has Str $.url is rw;
    #| Represents an email address of the contact person/organization.
    has Str $.email is rw;

    # Getters
    #| Returns a name of the contact person/organization or Nil.
    method name() { $!name // Nil }
    #| Returns a URL pointing to the contact information or Nil.
    method url() { $!url // Nil }
    #| Returns an email address of the contact person/organization or Nil.
    method email() { $!email // Nil }
}

#| The OpenAPI::Model::Discriminator class represents an L<OpenAPI Discriminator object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#discriminatorObject>.
class OpenAPI::Model::Discriminator does OpenAPI::Model::Element[
    scalar => {
        propertyName => {
            attr => 'property-name'
        },
        mapping => {}
    },
    object => {}] {
    #| Represents name of the property in the payload that will hold the discriminator value.
    has Str $.property-name is required is rw;
    #| Represents hash that holds schema names or references by payload values.
    has Str %.mapping is rw;

    # Getters
    #| Returns name of the property in the payload that will hold the discriminator value.
    method property-name() { $!property-name // Nil }
    #| Returns hash that holds schema names or references by payload values.
    method mapping() { %!mapping }
}

#| The OpenAPI::Model::Encoding class represents an L<OpenAPI Encoding object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#encodingObject>.
class OpenAPI::Model::Encoding does OpenAPI::Model::Element[
    scalar => {
        contentType => {
            attr => 'content-type'
        },
        style => {},
        explode => {},
        allowReserved => {
            attr => 'allow-reserved'
        }
    },
    object => {
        headers => {
            hash => True,
            ref => True,
            type => OpenAPI::Model::Header
        }
    }] {
    #| Represents content-type for encoding a specific property.
    has Str $.content-type is rw;
    #| Represents a hash that holds additional information to be provided as headers.
    has RefHeader %.headers;
    #| Represents style of how the parameter is serialized.
    subset Style of Str where 'simple'|'label'|'matrix'|'form'|'pipeDelimited'|'spaceDelimited';
    has Style $.style is rw;
    #| Represents `explode` flag for serialization logic.
    has Bool $.explode is rw;
    #| Represents `allowReserved` flag for serialization logic.
    has Bool $.allow-reserved is rw;

    # Getters
    #| Returns content-type for encoding a specific property.
    method content-type() { $!content-type // Nil }
    #| Returns a hash that holds reusable Header Objects.
    method headers() { %!headers.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Header) }).Hash }
    method raw-headers() { %!headers }
    #| Returns style of how the parameter is serialized.
    method style() { $!style // Nil }
    #| Returns `explode` flag for serialization logic.
    method explode() { $!explode // Nil }
    #| Returns `allowReserved` flag for serialization logic.
    method allow-reserved() { $!allow-reserved // Nil }

    # Object getters
    method get-header(Str $id) { self!resolve(%!headers{$id}, expect => OpenAPI::Model::Header) }
    method get-raw-header(Str $id) { %!headers{$id} }

    # Setters
    #| Adds header into encoding by id.
    method set-header(Str $id, RefHeader:D $header --> Nil) { %!headers{$id} = $header }
    #| Deletes header from encoding by id.
    method delete-header(Str $id) { %!headers{$id}:delete }
}

#| The OpenAPI::Model::Example class represents an L<OpenAPI Example Documentation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#exampleObject>.
class OpenAPI::Model::Example does OpenAPI::Model::Element[
    scalar => {
        summary => {},
        description => {},
        value => {},
        externalValue => {
            attr => 'external-value'
        }
    },
    object => {}] {
    #| Represents short description for the example.
    has Str $.summary is rw;
    #| Represents long description for the example.
    has Str $.description is rw;
    #| Represents embedded liberal example.
    has $.value is rw;
    #| Represents URL that points to the literal example.
    has Str $.external-value is rw;

    # Getters
    #| Returns short description for the example or Nil.
    method summary() { $!summary // Nil }
    #| Returns long description for the example or Nil.
    method description() { $!description // Nil }
    #| Returns embedded liberal example or Nil.
    method value() { $!value // Nil }
    #| Returns URL that points to the literal example or Nil.
    method external-value() { $!external-value // Nil }
}

#| The OpenAPI::Model::ExternalDocs class represents an L<OpenAPI External Documentation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#externalDocumentationObject>.
class OpenAPI::Model::ExternalDocs does OpenAPI::Model::Element[
    scalar => {
        description => {},
        url => {}
    },
    object => {}] {
    #| Represents a short description of the target documentation.
    has Str $.description is rw;
    #| Represents a URL for the target documentation.
    has Str $.url is required is rw;

    # Getters
    #| Returns a short description of the target documentation or Nil.
    method description() { $!description // Nil }
    #| Returns a URL for the target documentation or Nil.
    method url() { $!url // Nil }
}

#| The OpenAPI::Model::Info class represents an L<OpenAPI Info object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#infoObject>.
class OpenAPI::Model::Info does OpenAPI::Model::Element[
    scalar => {
        title => {},
        description => {},
        termsOfService => {
            attr => 'terms-of-service'
        },
        version => {}
    },
    object => {
        contact => {
            type => OpenAPI::Model::Contact
        },
        license => {
            type => OpenAPI::Model::License
        }
    }] {
    #| Represents an application title.
    has Str $.title is required is rw;
    #| Represents an application description.
    has Str $.description is rw;
    #| Represents a URL to the Terms of Service for the API.
    has Str $.terms-of-service is rw;
    #| Represents a version of the OpenAPI document.
    has Str $.version is required is rw;
    #| Represents an L<OpenAPI Contact object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#contactObject>.
    has OpenAPI::Model::Contact $.contact;
    #| Represents an L<OpenAPI License object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#licenseObject>.
    has OpenAPI::Model::License $.license;

    # Getters
    #| Returns an application title or Nil.
    method title() { $!title // Nil }
    #| Returns an application description or Nil.
    method description() { $!description // Nil }
    #| Returns a URL to the Terms of Service for the API or Nil.
    method terms-of-service() { $!terms-of-service // Nil }
    #| Returns a version of the OpenAPI document or Nil.
    method version() { $!version // Nil }
    #| Returns an L<OpenAPI Contact object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#contactObject> or Nil.
    method contact() { $!contact // Nil }
    #| Returns an L<OpenAPI License object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#licenseObject> or Nil.
    method license() { $!license // Nil }

    # Setters
    #| Sets Contact to Nil.
    multi method set-contact(Any:U) { $!contact = Nil }
    #| Sets Contact to given value.
    multi method set-contact(OpenAPI::Model::Contact:D $!contact --> Nil) {
        $!contact.set-model($!model);
    }

    #| Sets License to Nil.
    multi method set-license(Any:U) { $!license = Nil }
    #| Sets License to given value.
    multi method set-license(OpenAPI::Model::License:D $!license --> Nil) {
        $!license.set-model($!model);
    }
}

#| The OpenAPI::Model::License class represents an L<OpenAPI License object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#licenseObject>.
class OpenAPI::Model::License does OpenAPI::Model::Element[
    scalar => {
        name => {},
        url => {},
    }] {
    #| Represents the license name used for the API.
    has Str $.name is rw;
    #| Represents a URL to the license used for the API.
    has Str $.url is rw;

    # Getters
    #| Returns the license name used for the API or Nil.
    method name() { $!name // Nil }
    #| Returns a URL to the license used for the API or Nil.
    method url() { $!url // Nil }
}

#| The OpenAPI::Model::Link class represents an L<OpenAPI Link object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#linkObject>.
class OpenAPI::Model::Link does OpenAPI::Model::Element[
    scalar => {
        operationRef => {
            attr => 'operation-ref'
        },
        operationId => {
            attr => 'operation-id'
        },
        parameters => {},
        requestBody => {
            attr => 'request-body'
        },
        description => {}
    },
    object => {
        server => {
            type => OpenAPI::Model::Server
        }
    }] {
    #| Represents relative or absolute reference to an OAS operation.
    has Str $.operation-ref is rw;
    #| Represents name of an existing, resolvable OAS operation, as defined with a unique operationId.
    has Str $.operation-id is rw;
    #| Represents a hash that holds parameters to pass.
    has %.parameters is rw;
    #| Represents value to use as a request body when calling the target operation.
    has $.request-body is rw;
    #| Represents description of the link.
    has Str $.description is rw;
    #| Represents server object to be used by the target operation.
    has OpenAPI::Model::Server $.server;

    # Getters
    #| Returns relative or absolute reference to an OAS operation or Nil.
    method operation-ref() { $!operation-ref // Nil }
    #| Returns name of an existing, resolvable OAS operation, as defined with a unique operationId or Nil.
    method operation-id() { $!operation-id // Nil }
    #| Returns a hash that holds parameters to pass or Nil.
    method parameters() { %!parameters }
    #| Returns value to use as a request body when calling the target operation or Nil.
    method request-body() { $!request-body // Nil }
    #| Returns description of the link or Nil.
    method description() { $!description // Nil }
    #| Returns server object to be used by the target operation or Nil.
    method server() { $!server // Nil }

    # Setters
    #| Sets server to Nil.
    multi method set-server(Any:U) { $!server = Nil }
    #| Sets server to given value.
    multi method set-server(OpenAPI::Model::Server:D $!server --> Nil) {
        $!server.set-model($!model);
    }
}

#| The OpenAPI::Model::MediaType class represents an L<OpenAPI Media Type object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#mediaTypeObject>.
class OpenAPI::Model::MediaType does OpenAPI::Model::Element[
    scalar => {
        example => {}
    },
    object => {
        schema => {
            ref => True,
            raw => True,
            type => OpenAPI::Model::Schema
        },
        examples => {
            ref => True,
            hash => True,
            type => OpenAPI::Model::Example
        },
        encoding => {
            hash => True,
            type => OpenAPI::Model::Encoding
        }
    }] {
    #| Represents schema defining the type used for the request body.
    has RefSchema $.schema;
    #| Represents example of the media type.
    has $.example;
    #| Represents examples of the media type.
    has RefExample %.examples;
    #| Represents a hash that holds Encoding objects of this Media Type.
    has OpenAPI::Model::Encoding %.encoding;

    # Getters
    #| Returns schema defining the type used for the request body.
    method schema() { self!resolve-schema($!schema.container) // Nil }
    method raw-schema() { $!schema // Nil }
    #| Returns an example of the media type.
    method example() { $!example // Nil }
    #| Returns examples of the media type.
    method examples() { %!examples.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Example) }).Hash }
    method raw-examples() { %!examples }
    #| Returns a hash that holds Encoding objects of this Media Type.
    method encoding() { %!encoding }

    # Object getters
    method get-example(Str $id) { self!resolve(%!examples{$id}, expect => OpenAPI::Model::Example) }
    method get-raw-example(Str $id) { %!examples{$id} }

    # Setters
    #| Sets schema to Nil.
    multi method set-schema(Any:U) { $!schema = Nil }
    #| Sets schema to given value.
    multi method set-schema(RefSchema:D $!schema --> Nil) {
        $!schema.set-model($!model);
    }

    #| Sets example to given value.
    method set-example($!example --> Nil) {
        %!examples = Hash.new;
    }

    #| Adds example into media type by id.
    method set-examples(Str $id, RefExample:D $example --> Nil) {
        $!example = Nil;
        %!examples{$id} = $example;
    }
    #| Deletes schema from media type by id.
    method delete-examples(Str $id) { %!examples{$id}:delete }

    #| Adds encoding into media type by id.
    method set-encoding(Str $id, OpenAPI::Model::Encoding:D $encoding --> Nil) { %!encoding{$id} = $encoding }
    #| Deletes encoding from media type by id.
    method delete-encoding(Str $id) { %!encoding{$id}:delete }
}

#| The OpenAPI::Model::OAuthFlow class represents an L<OpenAPI OAuthFlow object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#oauthFlowObject>.
class OpenAPI::Model::OAuthFlow does OpenAPI::Model::Element[
    scalar => {
        authorizationUrl => {
            attr => 'authorization-url'
        },
        tokenUrl => {
            attr => 'token-url'
        },
        refreshUrl => {
            attr => 'refresh-url'
        },
        scopes => {}
    },
    object => {}] {
    #| Represents authorization URL to be used for this flow.
    has Str $.authorization-url is required is rw;
    #| Represents token URL to be used for this flow.
    has Str $.token-url is required is rw;
    #| Represents URL to be used for obtaining refresh tokens.
    has Str $.refresh-url is rw;
    #| Represents a hash that holds available scopes for the OAuth2 security scheme.
    has Str %.scopes;

    # Getters
    #| Returns authorization URL to be used for this flow or Nil.
    method authorization-url() { $!authorization-url // Nil }
    #| Returns token URL to be used for this flow or Nil.
    method token-url() { $!token-url // Nil }
    #| Returns URL to be used for obtaining refresh tokens or Nil.
    method refresh-url() { $!refresh-url // Nil }
    #| Returns a hash that holds available scopes for the OAuth2 security scheme or Nil.
    method scopes() { %!scopes }
}

#| The OpenAPI::Model::OAuthFlows class represents an L<OpenAPI OAuthFlows object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#oauthFlowsObject>.
class OpenAPI::Model::OAuthFlows does OpenAPI::Model::Element[
    scalar => {},
    object => {
        implicit => {
            type => OpenAPI::Model::OAuthFlow
        },
        password => {
            type => OpenAPI::Model::OAuthFlow
        },
        clientCredentials => {
            attr => 'client-credentials',
            type => OpenAPI::Model::OAuthFlow
        },
        authorizationCode => {
            attr => 'authorization-code',
            type => OpenAPI::Model::OAuthFlow
        },
    }] {
    #| Represents configuration for the OAuth Implicit flow.
    has OpenAPI::Model::OAuthFlow $.implicit;
    #| Represents configuration for the OAuth Resource Owner Password flow.
    has OpenAPI::Model::OAuthFlow $.password;
    #| Represents configuration for the OAuth Client Credentials flow.
    has OpenAPI::Model::OAuthFlow $.client-credentials;
    #| Represents configuration for the OAuth Authorization Code flow.
    has OpenAPI::Model::OAuthFlow $.authorization-code;

    # Getters
    #| Returns configuration for the OAuth Implicit flow or Nil.
    method implicit() { $!implicit // Nil };
    #| Returns configuration for the OAuth Resource Owner Password flow or Nil.
    method password() { $!password // Nil };
    #| Returns configuration for the OAuth Client Credentials flow or Nil.
    method client-credentials() { $!client-credentials // Nil };
    #| Returns configuration for the OAuth Authorization Code flow or Nil.
    method authorization-code() { $!authorization-code // Nil };

    # Setters
    #| Sets Implicit based flow to Nil.
    multi method set-implicit(Any:U) { $!implicit = Nil }
    #| Sets Implicit based flow to given value.
    multi method set-implicit(OpenAPI::Model::OAuthFlow:D $!implicit --> Nil) {
        $!implicit.set-model($!model);
    }

    #| Sets Password based flow to Nil.
    multi method set-password(Any:U) { $!password = Nil }
    #| Sets Password based flow to given value.
    multi method set-password(OpenAPI::Model::OAuthFlow:D $!password --> Nil) {
        $!password.set-model($!model);
    }

    #| Sets Client Credentials based flow to Nil.
    multi method set-client-credentials(Any:U) { $!client-credentials = Nil }
    #| Sets Client Credentials based flow to given value.
    multi method set-client-credentials(OpenAPI::Model::OAuthFlow:D $!client-credentials --> Nil) {
        $!client-credentials.set-model($!model);
    }

    #| Sets Authorization-Code based flow to Nil.
    multi method set-authorization-code(Any:U) { $!authorization-code = Nil }
    #| Sets Authorization-Code based flow to given value.
    multi method set-authorization-code(OpenAPI::Model::OAuthFlow:D $!authorization-code --> Nil) {
        $!authorization-code.set-model($!model);
    }
}

#| The OpenAPI::Model::Operation class represents an L<OpenAPI Operation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject>.
class OpenAPI::Model::Operation does OpenAPI::Model::Element[
    scalar => {
        tags => {},
        summary => {},
        description => {},
        operationId => {
            attr => 'operation-id'
        },
        deprecated => {}
    },
    object => {
        externalDocs => {
            attr => 'external-docs',
            type => OpenAPI::Model::ExternalDocs
        },
        parameters => {
            ref => True,
            array => True,
            type => OpenAPI::Model::Parameter
        },
        requestBody => {
            attr => 'request-body',
            ref => True,
            type => OpenAPI::Model::RequestBody
        },
        responses => {
            type => OpenAPI::Model::Responses
        },
        callbacks => {
            hash => True,
            ref => True,
            type => OpenAPI::Model::Callback
        },
        security => {
            array => True,
            type => OpenAPI::Model::Security
        },
        servers => {
            array => True,
            type => OpenAPI::Model::Server
        }
    }] {
    #| Represents a list of tags for API documentation control.
    has Str @.tags is rw;
    #| Represents a short summary of what the operation does.
    has Str $.summary is rw;
    #| Represents a verbose explanation of the operation behavior.
    has Str $.description is rw;
    #| Represents a unique string used to identify the operation.
    has Str $.operation-id is rw;
    #| Represents a boolean value that indicates whether operation is deprecated or not.
    has Bool $.deprecated is rw;
    #| Represents an L<OpenAPI External Documentation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#externalDocumentationObject>.
    has OpenAPI::Model::ExternalDocs $.external-docs;
    #| Represents an Array of L<OpenAPI Parameter objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#parameterObject>.
    has RefParameter @.parameters;
    #| Represents an L<OpenAPI Contact object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#requestBodyObject>.
    has RefRequestBody $.request-body;
    #| Represents an L<OpenAPI Contact object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#responsesObject>.
    has OpenAPI::Model::Responses $.responses;
    #| Represents an L<OpenAPI Contact object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#callbackObject>.
    has RefCallback %.callbacks;
    #| Represents an Array of L<OpenAPI Security Requirement objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#securityRequirementObject>.
    has OpenAPI::Model::Security @.security;
    #| Represents an Array of L<OpenAPI Server objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#serverObject>.
    has OpenAPI::Model::Server @.servers;

    # Getters
    #| Returns a list of tags for API documentation control or Nil.
    method tags() { @!tags }
    #| Returns a short summary of what the operation does or Nil.
    method summary() { $!summary // Nil }
    #| Returns a verbose explanation of the operation behavior or Nil.
    method description() { $!description // Nil }
    #| Returns a unique string used to identify the operation or Nil.
    method operation-id() { $!operation-id // Nil }
    #| Returns a boolean value that indicates whether operation is deprecated or not or Nil.
    method deprecated() { $!deprecated // Nil }
    #| Returns an L<OpenAPI External Documentation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#externalDocumentationObject> or Nil.
    method external-docs() { $!external-docs // Nil }
    #| Returns an Array of L<OpenAPI Parameter objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#parameterObject> or Nil.
    method parameters() { @!parameters.map({self!resolve($_, expect => OpenAPI::Model::Parameter)}).List }
    method raw-parameters() { @!parameters }
    #| Returns an L<OpenAPI Request Body object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#requestBodyObject> or Nil.
    method request-body() { self!resolve($!request-body, expect => OpenAPI::Model::RequestBody) // Nil }
    method raw-request-body() { $!request-body // Nil }
    #| Returns an L<OpenAPI Responses object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#responsesObject> or Nil.
    method responses() { $!responses // Nil }
    #| Returns a Hash of L<OpenAPI Callback objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#callbackObject> or Nil.
    method callbacks() { %!callbacks.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Callback) }).Hash }
    method raw-callbacks() { %!callbacks }
    #| Returns an Array of L<OpenAPI Security Requirement objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#securityRequirementObject> or Nil.
    method security() { @!security }
    #| Returns an Array of L<OpenAPI Server objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#serverObject> or Nil.
    method servers() { @!servers }

    # Object getters
    method get-callback(Str $id) { self!resolve(%!callbacks{$id}, expect => OpenAPI::Model::Callback) }
    method get-raw-callback(Str $id) { %!callbacks{$id} }

    # Setters
    #| Sets External Documentation to Nil.
    multi method set-external-docs(Any:U) { $!external-docs = Nil }
    #| Sets External Documentation to given value.
    multi method set-external-docs(OpenAPI::Model::ExternalDocs:D $!external-docs --> Nil) {
        $!external-docs.set-model($!model);
    }

    #| Adds given Parameter to parameters array.
    multi method add-parameter(RefParameter $parameter) { $parameter.set-model($!model); @!parameters.push: $parameter }
    #| Removes given Parameter from parameters array.
    multi method remove-parameter(RefParameter $parameter --> Nil) { @!parameters .= grep({ not $_ eqv $parameter}) }

    #| Sets Request Body to Nil.
    multi method set-request-body(Any:U) { $!request-body = Nil }
    #| Sets Request Body to given value.
    multi method set-request-body(RefRequestBody:D $!request-body --> Nil) {
        $!request-body.set-model($!model);
    }

    #| Sets Responses to Nil.
    multi method set-responses(Any:U) { $!responses = Nil }
    #| Sets Responses to given value.
    multi method set-responses(OpenAPI::Model::Responses:D $!responses --> Nil) {
        $!responses.set-model($!model);
    }

    #| Adds callback for the operation by id.
    method set-callback(Str $id, RefCallback:D $callback --> Nil) {
        %!callbacks{$id} = $callback;
    }
    #| Deletes callback for the operation by id.
    method delete-callback(Str $id) {
        %!callbacks{$id}:delete;
    }

    #| Adds given Security Requirenments to Security Requirenments array.
    multi method add-security(OpenAPI::Model::Security $security) { @!security.push: $security }
    #| Removes given Security Requirenments from Security Requirenments array.
    multi method remove-security(OpenAPI::Model::Security $security --> Nil) { @!security .= grep({ not $_ eqv $security}) }

    #| Adds given Server to Server array.
    multi method add-server(OpenAPI::Model::Server $server) { @!servers.push: $server }
    #| Removes given Server from Server array.
    multi method remove-server(OpenAPI::Model::Server $server --> Nil) { @!servers .= grep({ not $_ eqv $server}) }
}

#| The OpenAPI::Model::Parameter class represents an L<OpenAPI Parameter object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#parameterObject>.
class OpenAPI::Model::Parameter does OpenAPI::Model::Element[
    scalar => {
        name => {},
        in => {},
        description => {},
        required => {},
        deprecated => {},
        allowEmptyValue => {
            attr => 'allow-empty-value'
        },
        style => {},
        explode => {},
        allowReserved => {
            attr => 'allow-reserved'
        },
        example => {}
    },
    object => {
        schema => {
            type => OpenAPI::Model::Schema,
            raw => True,
            ref => True
        },
        examples => {
            type => OpenAPI::Model::Example,
            hash => True,
            ref => True
        },
        content => {
            type => OpenAPI::Model::MediaType,
            hash => True
        }
    }] {
    #| Represents name of the parameter.
    has Str $.name is rw;
    #| Represents location of the parameter.
    subset In of Str where 'query'|'header'|'path'|'cookie';
    has In $.in is rw;
    #| Represents a brief description of the parameter.
    has Str $.description is rw;
    #| Represents whether Parameter is required or not.
    has Bool $.required is rw;
    #| Represents whether Parameter is deprecated or not.
    has Bool $.deprecated is rw;
    #| Represents flag to define ability to pass empty-valued parameters.
    has Bool $.allow-empty-value is rw;
    #| Represents style of how the parameter is serialized.
    has Str $.style is rw;
    #| Represents `explode` flag for serialization logic.
    has Bool $.explode is rw;
    #| Represents `allowReserved` flag for serialization logic.
    has Bool $.allow-reserved is rw;
    #| Represents schema that defines the type used for the parameter.
    has RefSchema $.schema;
    #| Represents example of the media type.
    has $.example is rw;
    #| Represents a hash of examples based on media type.
    has RefExample %.examples;
    #| Represents a hash that holds representations of the parameter.
    has OpenAPI::Model::MediaType %.content;

    # Getters
    #| Returns name of the parameter.
    method name() { $!name // Nil }
    #| Returns location of the parameter.
    method in() { $!in // Nil }
    #| Returns a brief description of the parameter.
    method description() { $!description // Nil }
    #| Returns whether Parameter is required or not.
    method required() { $!required // Nil }
    #| Returns whether Parameter is deprecated or not.
    method deprecated() { $!deprecated // Nil }
    #| Returns flag to define ability to pass empty-valued parameters.
    method allow-empty-value() { $!allow-empty-value // Nil }
    #| Returns style of how the parameter is serialized.
    method style() { $!style // Nil }
    #| Returns `explode` flag for serialization logic.
    method explode() { $!explode // Nil }
    #| Returns `allowReserved` flag for serialization logic.
    method allow-reserved() { $!allow-reserved // Nil }
    #| Returns schema that defines the type used for the parameter.
    method schema() { self!resolve-schema($!schema.container) // Nil }
    method raw-schema() { $!schema // Nil }
    #| Returns example of the media type.
    method example() { $!example // Nil }
    #| Returns a hash of examples based on media type.
    method examples() { %!examples.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Examples) }).Hash }
    method raw-examples() { %!examples }
    #| Returns a hash that holds representations of the parameter.
    method content() { %!content }

    # Object getters
    method get-example(Str $id) { self!resolve(%!examples{$id}, expect => OpenAPI::Model::Example) }
    method get-raw-example(Str $id) { %!examples{$id} }

    # Setters
    #| Sets schema to Nil.
    multi method set-schema(Any:U) { $!schema = Nil }
    #| Sets schema to given value.
    multi method set-schema(RefSchema:D $!schema --> Nil) {
        $!schema.set-model($!model);
    }

    #| Sets example to given value.
    multi method set-example($!example --> Nil) {
        %!examples = Hash.new;
    }

    #| Adds example into Parameter by id.
    method set-examples(Str $id, RefExample:D $example --> Nil) {
        $!example = Nil;
        %!examples{$id} = $example;
    }
    #| Deletes schema from Parameter by id.
    method delete-examples(Str $id) { %!examples{$id}:delete }

    #| Adds content into Parameter by id.
    method set-content(Str $id, OpenAPI::Model::MediaType:D $content --> Nil) { %!content{$id} = $content }
    #| Deletes content from Parameter by id.
    method delete-content(Str $id) { %!content{$id}:delete }
}

#| The OpenAPI::Model::Header class represents an L<OpenAPI Header object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#headerObject>.
class OpenAPI::Model::Header is OpenAPI::Model::Parameter {}

#| The OpenAPI::Model::Path class represents an L<OpenAPI Path object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#pathItemObject>.
class OpenAPI::Model::Path does OpenAPI::Model::Element[
    scalar => {
        '$ref' => {
            attr => 'ref'
        },
        summary => {},
        description => {}
    },
    object => {
        get => {
            type => OpenAPI::Model::Operation
        },
        put => {
            type => OpenAPI::Model::Operation
        },
        post => {
            type => OpenAPI::Model::Operation
        },
        delete => {
            type => OpenAPI::Model::Operation
        },
        options => {
            type => OpenAPI::Model::Operation
        },
        head => {
            type => OpenAPI::Model::Operation
        },
        patch => {
            type => OpenAPI::Model::Operation
        },
        trace => {
            type => OpenAPI::Model::Operation
        },
        servers => {
            array => True,
            type => OpenAPI::Model::Server,
        },
        parameters => {
            ref => True,
            array => True,
            type => OpenAPI::Model::Parameter
        }
    }] {
    #| Represents an external definition of this path item.
    has Str $.ref is rw;
    #| Represents an optional, string summary, intended to apply to all operations in this path.
    has Str $.summary is rw;
    #| Represents an optional, string description, intended to apply to all operations in this path.
    has Str $.description is rw;
    #| Represents a definition of a GET operation on this path.
    has OpenAPI::Model::Operation $.get;
    #| Represents a definition of a PUT operation on this path.
    has OpenAPI::Model::Operation $.put;
    #| Represents a efinition of a POST operation on this path.
    has OpenAPI::Model::Operation $.post;
    #| Represents a definition of a DELETE operation on this path.
    has OpenAPI::Model::Operation $.delete;
    #| Represents a definition of a OPTIONS operation on this path.
    has OpenAPI::Model::Operation $.options;
    #| Represents a definition of a HEAD operation on this path.
    has OpenAPI::Model::Operation $.head;
    #| Represents a definition of a PATCH operation on this path.
    has OpenAPI::Model::Operation $.patch;
    #| Represents a definition of a TRACE operation on this path.
    has OpenAPI::Model::Operation $.trace;
    #| Represents an alternative server array to service all operations in this path.
    has OpenAPI::Model::Server @.servers;
    #| Represents a list of parameters that are applicable for all the operations described under this path. 
    has RefParameter @.parameters;

    # Getters
    #| Returns an L<OpenAPI Operation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject> or Nil.
    method get() { $!get // Nil }
    #| Returns an L<OpenAPI Operation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject> or Nil.
    method put() { $!put // Nil }
    #| Returns an L<OpenAPI Operation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject> or Nil.
    method post() { $!post // Nil }
    #| Returns an L<OpenAPI Operation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject> or Nil.
    method delete() { $!delete // Nil }
    #| Returns an L<OpenAPI Operation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject> or Nil.
    method options() { $!options // Nil }
    #| Returns an L<OpenAPI Operation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject> or Nil.
    method head() { $!head // Nil }
    #| Returns an L<OpenAPI Operation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject> or Nil.
    method patch() { $!patch // Nil }
    #| Returns an L<OpenAPI Operation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#operationObject> or Nil.
    method trace() { $!trace // Nil }
    #| Returns an Array of L<OpenAPI Server objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#serverObject> or Nil.
    method servers() { @!servers }
    #| Returns an Array of L<OpenAPI Parameter objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#parameterObject> or Nil.
    method parameters() { @!parameters.map({self!resolve($_, expect => OpenAPI::Model::Parameter)}).List }
    method raw-parameters() { @!parameters }

    # Setters
    #| Sets get to Nil.
    multi method set-get(Any:U) { $!get = Nil }
    #| Sets get to given value.
    multi method set-get(OpenAPI::Model::Operation:D $!get --> Nil) {
        $!get.set-model($!model);
    }

    #| Sets put to Nil.
    multi method set-put(Any:U) { $!put = Nil }
    #| Sets put to given value.
    multi method set-put(OpenAPI::Model::Operation:D $!put --> Nil) {
        $!put.set-model($!model);
    }

    #| Sets post to Nil.
    multi method set-post(Any:U) { $!post = Nil }
    #| Sets post to given value.
    multi method set-post(OpenAPI::Model::Operation:D $!post --> Nil) {
        $!post.set-model($!model);
    }

    #| Sets delete to Nil.
    multi method set-delete(Any:U) { $!delete = Nil }
    #| Sets delete to given value.
    multi method set-delete(OpenAPI::Model::Operation:D $!delete --> Nil) {
        $!delete.set-model($!model);
    }

    #| Sets options to Nil.
    multi method set-options(Any:U) { $!options = Nil }
    #| Sets options to given value.
    multi method set-options(OpenAPI::Model::Operation:D $!options --> Nil) {
        $!options.set-model($!model);
    }

    #| Sets head to Nil.
    multi method set-head(Any:U) { $!head = Nil }
    #| Sets head to given value.
    multi method set-head(OpenAPI::Model::Operation:D $!head --> Nil) {
        $!head.set-model($!model);
    }

    #| Sets patch to Nil.
    multi method set-patch(Any:U) { $!patch = Nil }
    #| Sets patch to given value.
    multi method set-patch(OpenAPI::Model::Operation:D $!patch --> Nil) {
        $!patch.set-model($!model);
    }

    #| Sets trace to Nil.
    multi method set-trace(Any:U) { $!trace = Nil }
    #| Sets trace to given value.
    multi method set-trace(OpenAPI::Model::Operation:D $!trace --> Nil) {
        $!trace.set-model($!model);
    }

    #| Adds given Server to Server array.
    multi method add-server(OpenAPI::Model::Server $server) { $server.set-model($!model); @!servers.push: $server }
    #| Removes given Server from Server array.
    multi method remove-server(OpenAPI::Model::Server $server --> Nil) { @!servers .= grep({ not $_ eqv $server}) }

    #| Adds given Parameter to parameters array.
    multi method add-parameter(RefParameter $parameter) { $parameter.set-model($!model); @!parameters.push: $parameter }
    #| Removes given Parameter from parameters array.
    multi method remove-parameter(RefParameter $parameter --> Nil) { @!parameters .= grep({ not $_ eqv $parameter}) }
}

#| The OpenAPI::Model::Paths class represents an L<OpenAPI Paths object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#pathsObject>.
class OpenAPI::Model::Paths does OpenAPI::Model::PatternedObject does OpenAPI::Model::Element[
    scalar => {},
    object => {},
    :patterned(OpenAPI::Model::Path)] {
    method serialize() { self.OpenAPI::Model::PatternedObject::serialize() }

    #| Adds path to paths by id.
    method set-path(Str $id, OpenAPI::Model::Path $path) { %!container{$id} = $path }
    #| Deletes path from paths by id.
    method delete-path(Str $id) { %!container{$id}:delete }
    #| Returns OpenAPI::Model::Path object  by id.
    method get-path(Str $id) { %!container{$id} }
}

#| The OpenAPI::Model::RequestBody class represents an L<OpenAPI Request Body object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#requestBodyObject>.
class OpenAPI::Model::RequestBody does OpenAPI::Model::Element[
    scalar => {
        description => {},
        required => {}
    },
    object => {
        content => {
            hash => True,
            type => OpenAPI::Model::MediaType
        }
    }] {
    #| Represents a brief description of the request body.
    has Str $.description is rw;
    #| Represents the content of the request body.
    has OpenAPI::Model::MediaType %.content is required;
    #| Represents a bool that describes if request body is required in the request.
    has Bool $.required is rw;

    # Getters
    #| Returns a brief description of the request body.
    method description() { $!description // Nil }
    #| Returns the content of the request body.
    method content() { %!content }
    #| Returns a bool that describes if request body is required in the request.
    method required() { $!required // Nil }

    # Setters
    #| Adds content into Request Body by id.
    method set-content(Str $id, OpenAPI::Model::MediaType:D $content --> Nil) { %!content{$id} = $content }
    #| Deletes content from Request Body by id.
    method delete-content(Str $id) { %!content{$id}:delete }
}

#| The OpenAPI::Model::Response class represents an L<OpenAPI Response object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#responseObject>.
class OpenAPI::Model::Response does OpenAPI::Model::Element[
    scalar => {
        description => {}
    },
    object => {
        headers => {
            ref => True,
            hash => True,
            type => OpenAPI::Model::Header
        },
        content => {
            hash => True,
            type => OpenAPI::Model::MediaType
        },
        links => {
            ref => True,
            hash => True,
            type => OpenAPI::Model::Link
        }
    }] {
    #| Represents a short description of the response.
    has Str $.description is required is rw;
    #| Represents a hash that maps a header name to its definition.
    has RefHeader %.headers;
    #| Represents a hash that maps media types to Media Type objects.
    has OpenAPI::Model::MediaType %.content;
    #| Represents a hash that holds operations links that can be followed from the response.
    has RefLink %.links;

    # Getters
    #| Returns a short description of the response or Nil.
    method description() { $!description // Nil }
    #| Returns a hash that holds headers or Nil.
    method headers() { %!headers.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Header) }).Hash }
    method raw-headers() { %!headers }
    #| Returns a hash that holds OpenAPI::Model::MediaType objects of the Response or Nil.
    method content() { %!content }
    #| Returns a hash that holds operation links.
    method links() { %!links.map({ .key => self!resolve(.value, expect => OpenAPI::Model::Link) }).Hash }
    method raw-links() { %!links }

    # Object getters
    method get-header(Str $id) { self!resolve(%!headers{$id}, expect => OpenAPI::Model::Header) }
    method get-raw-header(Str $id) { %!headers{$id} }
    method get-link(Str $id) { self!resolve(%!links{$id}, expect => OpenAPI::Model::Link) }
    method raw-get-link(Str $id) { %!links{$id} }

    # Setters
    #| Adds header into response by id.
    method set-header(Str $id, RefHeader:D $header --> Nil) { %!headers{$id} = $header }
    #| Deletes header from response by id.
    method delete-header(Str $id) { %!headers{$id}:delete }

    #| Adds content into response by id.
    method set-content(Str $id, OpenAPI::Model::MediaType:D $content --> Nil) { %!content{$id} = $content }
    #| Deletes content from response by id.
    method delete-content(Str $id) { %!content{$id}:delete }

    #| Adds link into response by id.
    method set-link(Str $id, RefLink:D $link --> Nil) { %!links{$id} = $link }
    #| Deletes link from response by id.
    method delete-link(Str $id) { %!links{$id}:delete }
}

#| The OpenAPI::Model::Responses class represents an L<OpenAPI Responses object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#responsesObject>.
class OpenAPI::Model::Responses does OpenAPI::Model::PatternedObject does OpenAPI::Model::Element[
    scalar => {},
    object => {},
    :patterned([OpenAPI::Model::Response, OpenAPI::Model::Reference])] {
    method serialize() { self.OpenAPI::Model::PatternedObject::serialize() }

    #| Adds response to responses by id.
    method set-response(Str $id, OpenAPI::Model::Response $response) { %!container{$id} = $response }
    #| Deletes response from responses by id.
    method delete-response(Str $id) { %!container{$id}:delete }
    #| Returns OpenAPI::Model::Response object by id.
    method get-response(Str $id) { self!resolve(%!container{$id}, expect => OpenAPI::Model::Response) }
    method get-raw-response(Str $id) { %!container{$id} }
}

#| The OpenAPI::Model::Schema class represents an L<OpenAPI Schema object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#schemaObject>.
class OpenAPI::Model::Schema does OpenAPI::Model::PatternedObject does OpenAPI::Model::Element[
    scalar => {},
    object => {}] {

    method serialize() { %!container }
}

#| The OpenAPI::Model::Security class represents an L<OpenAPI Security Requirement object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#securityRequirementObject>.
class OpenAPI::Model::Security does OpenAPI::Model::PatternedObject does OpenAPI::Model::Element[
    scalar => {},
    object => {},
    :patterned] {
    method serialize() { self.OpenAPI::Model::PatternedObject::serialize() }

    #| Adds security rule into security requirements scheme by id.
    method set-security(Str $id, Str @scheme) { %!container{$id} = @scheme }
    #| Deletes security rule from security requirements scheme by id.
    method delete-security(Str $id) { %!container{$id}:delete }
    #| Returns array of security rules by id.
    method get-security(Str $id) { %!container{$id} }
}

#| The OpenAPI::Model::SecurityScheme class represents an L<OpenAPI Security Scheme object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#securitySchemeObject>.
class OpenAPI::Model::SecurityScheme does OpenAPI::Model::Element[
    scalar => {
        type => {},
        description => {},
        name => {},
        in => {},
        scheme => {},
        bearerFormat => {
            attr => 'bearer-format'
        },
        openIdConnectUrl => {
            attr => 'open-id-connect-url'
        }
    },
    object => {
        flows => {
            type => OpenAPI::Model::OAuthFlows
        }
    }] {
    #| Represents type of the security scheme.
    subset Scheme of Str where 'apiKey'|'http'|'oauth2'|'openIdConnect';
    has Scheme $.type is required is rw;
    #| Represents a short description for security scheme.
    has Str $.description is rw;
    #| Represents name of the header, query or cookie parameter to be used.
    has Str $.name is rw;
    #| Represents location of the API key.
    subset In of Str where 'query'|'header'|'cookie';
    has In $.in is rw;
    #| Represents name of the HTTP Authorization scheme.
    has Str $.scheme is rw;
    #| Represents hint to the client to identify how the bearer token is formatted.
    has Str $.bearer-format is rw;
    #| Represents an object containing configuration information for the flow types supported.
    has OpenAPI::Model::OAuthFlows $.flows;
    #| Represents OpenId Connect URL to discover OAuth2 configuration values.
    has Str $.open-id-connect-url is rw;

    submethod TWEAK(*%args) {
        given %args<type> {
            when 'apiKey' {
                unless %args<name>.defined && %args<in>.defined {
                    die X::OpenAPI::Model::InvalidFormat.new;
                }
            }
            when 'http' {
                unless %args<scheme>.defined {
                    die X::OpenAPI::Model::InvalidFormat.new;
                }
            }
            when 'oauth2' {
                unless %args<flows>.defined {
                    die X::OpenAPI::Model::InvalidFormat.new;
                }
            }
            when 'openIdConnect' {
                unless %args<openIdConnect>.defined {
                    die X::OpenAPI::Model::InvalidFormat.new;
                }
            }
        }
    }

    # Getters
    #| Returns type of the security scheme or Nil.
    method type() { $!type // Nil }
    #| Returns a short description for security scheme or Nil.
    method description() { $!description // Nil }
    #| Returns name of the header, query or cookie parameter to be used or Nil.
    method name() { $!name // Nil }
    #| Returns location of the API key or Nil.
    method in() { $!in // Nil }
    #| Returns name of the HTTP Authorization scheme or Nil.
    method scheme() { $!scheme // Nil }
    #| Returns hint to the client to identify how the bearer token is formatted or Nil.
    method bearer-format() { $!bearer-format // Nil }
    #| Returns an object containing configuration information for the flow types supported or Nil.
    method flows() { $!flows // Nil }
    #| Returns OpenId Connect URL to discover OAuth2 configuration values or Nil.
    method open-id-connect-url() { $!open-id-connect-url // Nil }

    # Setters
    #| Sets Contact to Nil.
    multi method set-flows(Any:U) { $!flows = Nil }
    #| Sets Contact to given value.
    multi method set-flows(OpenAPI::Model::OAuthFlows:D $!flows --> Nil) {
        $!flows.set-model($!model);
    }
}

#| The OpenAPI::Model::Server class represents an L<OpenAPI Server object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#serverObject>.
class OpenAPI::Model::Server does OpenAPI::Model::Element[
    scalar => {
        url => {},
        description => {}
    },
    object => {
        variables => {
            type => OpenAPI::Model::Variable,
            hash => True
        }
    }] {
    #| Represents a server url.
    has Str $.url is required is rw;
    #| Represents a server description.
    has Str $.description is rw;
    #| Represents a Hash of L<OpenAPI Server Variable objects hash|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#serverVariableObject>.
    has OpenAPI::Model::Variable %.variables;

    # Getters
    #| Returns a server url or Nil.
    method url() { $!url // Nil }
    #| Returns a server description or Nil.
    method description() { $!description // Nil }
    #| Returns a server variables or Nil.
    method variables() { %!variables }

    # Setters
    #| Adds variable for the server by id.
    method set-variable(Str $id, OpenAPI::Model::Variable:D $variable --> Nil) {
        %!variables{$id} = $variable;
    }
    #| Deletes variable of server by id.
    method delete-variable(Str $id) {
        %!variables{$id}:delete;
    }
}

#| The OpenAPI::Model::Tag class represents an L<OpenAPI Tag object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#tagObject>.
class OpenAPI::Model::Tag does OpenAPI::Model::Element[
    scalar => {
        name => {},
        description => {}
    },
    object => {
        externalDocs => {
            attr => 'external-docs',
            type => OpenAPI::Model::ExternalDocs
        }
    }] {
    #| Represents a name of the tag.
    has Str $.name is required is rw;
    #| Represents a short description for for the tag.
    has Str $.description is rw;
    #| Represents additional external documentation.
    has OpenAPI::Model::ExternalDocs $.external-docs is rw;

    # Getters
    #| Returns a name of the tag.
    method name() { $!name // Nil }
    #| Returns a short description for for the tag.
    method description() { $!description // Nil }
    #| Returns additional external documentation.
    method external-docs() { $!external-docs // Nil }

    # Setters
    #| Sets external documentation to Nil.
    multi method set-external-docs(Any:U) { $!external-docs = Nil }
    #| Sets external documentation to given value.
    multi method set-external-docs(OpenAPI::Model::ExternalDocs:D $!external-docs --> Nil) {
        $!external-docs.set-model($!model);
    }
}

#| The OpenAPI::Model::Variable class represents an L<OpenAPI Server Variable object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#serverVariableObject>.
class OpenAPI::Model::Variable does OpenAPI::Model::Element[
    scalar => {
        enum => {},
        default => {},
        description => {}
    }] {
    #| Represents an enumeration of string values to be used if the substitution options are from a limited set.
    has Str @.enum is rw;
    #| Represents the default value to use for substitution, and to send, if an alternate value is not supplied.
    has Str $.default is required is rw;
    #| Represents an optional description for the server variable.
    has Str $.description is rw;

    # Getters
    #| Returns  an enumeration of string values to be used if the substitution options are from a limited set or Nil.
    method enum() { @!enum }
    #| Returns the default value to use for substitution, and to send, if an alternate value is not supplied or Nil.
    method default() { $!default // Nil }
    #| Returns an optional description for the server variable or Nil.
    method description() { $!description // Nil }
}

#| The OpenAPI::Model::OpenAPI class represents an L<OpenAPI document object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#oasObject>.
class OpenAPI::Model::OpenAPI does OpenAPI::Model::Element[
    scalar => {
        openapi => {}
    },
    object => {
        info => {
            type => OpenAPI::Model::Info
        },
        servers => {
            type => OpenAPI::Model::Server,
            array => True
        },
        paths => {
            type => OpenAPI::Model::Paths
        },
        components => {
            type => OpenAPI::Model::Components
        },
        security => {
            type => OpenAPI::Model::Security,
            array => True
        },
        tags => {
            type => OpenAPI::Model::Tag,
            array => True
        },
        externalDocs => {
            attr => 'external-docs',
            type => OpenAPI::Model::ExternalDocs
        }
    }] {
    #| Represents an OpenAPI version.
    has Str $.openapi is required is rw;
    #| Represents an L<OpenAPI Info object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#infoObject>.
    has OpenAPI::Model::Info $.info is required;
    #| Represents an Array o L<OpenAPI Server objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#serverObject>.
    has OpenAPI::Model::Server @.servers;
    #| Represents an L<OpenAPI Paths object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#pathsObject>.
    has OpenAPI::Model::Paths $.paths is required;
    #| Represents an L<OpenAPI Components object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#componentsObject>.
    has OpenAPI::Model::Components $.components;
    #| Represents an L<OpenAPI Security Requirement object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#securityRequirementObject>.
    has OpenAPI::Model::Security @.security;
    #| Represents an Array of L<OpenAPI Tag objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#tagObject>.
    has OpenAPI::Model::Tag @.tags;
    #| Represents an L<OpenAPI External Documentation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#externalDocumentationObject>.
    has OpenAPI::Model::ExternalDocs $.external-docs;

    # Getters
    #| Returns an L<OpenAPI Info object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#infoObject> or Nil.
    method info() { $!info // Nil }
    #| Returns an Array of L<OpenAPI Server objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#serverObject> or Nil.
    method servers() { @!servers }
    #| Returns an L<OpenAPI Paths object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#pathsObject> or Nil.
    method paths() { $!paths // Nil }
    #| Returns an L<OpenAPI Components object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#componentsObject> or Nil.
    method components() { $!components // Nil }
    #| Returns an Array of L<OpenAPI Security Requirement objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#securityRequirementObject> or Nil.
    method security() { @!security }
    #| Returns an Array of L<OpenAPI Tag objects|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#tagObject> or Nil.
    method tags() { @!tags }
    #| Returns an L<OpenAPI External Documentation object|https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#externalDocumentationObject> or Nil.
    method external-docs() { $!external-docs // Nil }

    # Setters
    #| Sets Info to Nil.
    multi method set-info(Any:U) { $!info = Nil }
    #| Sets Info to given value.
    multi method set-info(OpenAPI::Model::Info:D $!info --> Nil) {
        $!info.set-model($!model);
    }

    #| Adds given Server to Server array.
    multi method add-server(OpenAPI::Model::Server $server) { @!servers.push: $server }
    #| Removes given Server from Server array.
    multi method remove-server(OpenAPI::Model::Server $server --> Nil) { @!servers .= grep({ not $_ eqv $server}) }

    #| Sets Paths to Nil.
    multi method set-paths(Any:U) { $!info = Nil }
    #| Sets Paths to given value.
    multi method set-paths(OpenAPI::Model::Paths:D $!paths --> Nil) {
        $!paths.set-model($!model);
    }

    #| Sets Components to Nil.
    multi method set-components(Any:U) { $!components = Nil }
    #| Sets Components to given value.
    multi method set-components(OpenAPI::Model::Components:D $!components --> Nil) {
        $!components.set-model($!model);
    }

    #| Adds given Security Requirenments to Security Requirenments array.
    multi method add-security(OpenAPI::Model::Security $security) { @!security.push: $security }
    #| Removes given Security Requirenments from Security Requirenments array.
    multi method remove-security(OpenAPI::Model::Security $security --> Nil) { @!security .= grep({ not $_ eqv $security}) }

    #| Adds given Tag to Tag array.
    multi method add-tag(OpenAPI::Model::Tag $tag) { @!tags.push: $tag }
    #| Removes given Tag from Tag array.
    multi method remove-tag(OpenAPI::Model::Tag $tag --> Nil) { @!tags .= grep({ not $_ eqv $tag}) }

    #| Sets External Documentation to Nil.
    multi method set-external-docs(Any:U) { $!external-docs = Nil }
    #| Sets External Documentation to given value.
    multi method set-external-docs(OpenAPI::Model::ExternalDocs:D $!external-docs --> Nil) {
        $!external-docs.set-model($!model);
    }
}
