### Class description

`OpenAPI::Model` is a base class that is used to parse a JSON or YAML
data into `OpenAPI::Model::OpenAPI`, root document object for OpenAPI.
It also can do reference resolution and will do it by default.

### Class methods

#### `from-json($json, :%external, :$check-references = True)`

This method constructs `OpenAPI::Model::OpenAPI` object based on JSON
passed as first argument. The user can pass external references as
`:%external` named argument to use it during reference
checking. `:$check-references` named argument can be used to control
whether references will be resolved at node construction time or
not. It is set to `True` by default, but can be overrided like that:

    my $doc = OpenAPI::Model.from-json($yaml, :!check-references);

#### `from-yaml($yaml, :%external, :$check-references)`

This method constructs `OpenAPI::Model::OpenAPI` object based on YAML
passed as first argument. The user can pass external references as
`:%external` named argument to use it during reference
checking. `:$check-references` named argument can be used to control
whether references will be resolved at node construction time or
not. It is set to `True` by default, but can be overrided like that:

    my $doc = OpenAPI::Model.from-yaml($yaml, :!check-references);
