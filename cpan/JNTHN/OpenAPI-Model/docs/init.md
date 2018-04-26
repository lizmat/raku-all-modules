# OpenAPI::Model

Work with OpenAPI documents in terms of a set of Perl 6 objects. Supports
parsing JSON or YAML OpenAPI documents into the object model, modifying them
or constructing new OpenAPI documents using the model objects, and saving the
document as either JSON or YAML. Implements [version 3 of the OpenAPI
specification](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md).


## Conventions

### Naming

The object model follows Perl 6 naming conventions, and names are mapped
accordingly. For example, `requestBody` in the specification can be accessed
by the `request-body` method on an `Operation` object. Element class names
follow the object names from the OpenAPI specification, thus the Operation
Object is `OpenAPI::Model::Operation`, or just `Operation` is the `:elements`
tag was imported.

### Optional values

Methods for optional elements that are not provided by the docuemnt will
consistently return `Nil`.

### References

In various places in an OpenAPI document, an object may be provided directly
or using a JSON Reference. For example, operation body schemas are often
provided in the `components` section and re-used in many operations. Some
use-cases of an OpenAPI model - such as a HTTP server plugin doing request
validation - will always want resolved references (that is, they will wish to
jump directly to the resolved object, without having to explicitly check for
and follow references). Other use-cases, such as building OpenAPI tooling,
will more likely care for the distinction.

To cater to both of these use-cases, `OpenAPI::Model` offers both resolved
and unresolved views. For example, the request body of an `Operation` may be
provided as a `RequestBody` object or a `Reference` object. Thus:

* The `request-body` property will always (try to) deference. Thus, provided
  there is a request body, it will return either a `RequestBody` object or, if
  the resolution fails, `fail` with `X::OpenAPI::Model::BadReference`. `Nil`
  is returned if there is no request body for the operation.
* The `raw-request-body` property will return either a `RequestBody` object
  or a `Reference` object, or `Nil` if there is no request body for the
  operation.
* The `set-request-body` property will accept either a concrete `RequestBody`
  object, a concrete `Reference` object, or any type object (including `Nil`).

### Changing the document

Properties that are simple scalar values (string, integer, etc.) are declared
as straightforward `is rw` properties. Any property with an object value is
instead set using a `set-` method. For collection properties, `add-` and
`remove-` methods are provided.

### Constructing object model elements

Constructors take named arguments. For non-scalar properties, the appropriate
`set-` method will be called for you. Thus:

```
my $op = Operation.new:
    request-body => $body,
    responses => Responses.new:
        default => Reference.new(ref => '#/components/schemas/Pet');
```

Is equivalent to:

```
my $op = Operation.new:
    responses => Responses.new:
        default => Reference.new(ref => '#/components/schemas/Pet');
$op.set-request-body($body);
```

### Patterned fields

Schema objects that support patterned fields implement `Associative` and the
methods:

* `kv`, `keys`, `values`, and `pairs`
* `AT-KEY` for accessing fields by key
* `EXISTS-KEY` for doing `:exists` checks

This is only for read-only access, and will always resolve any references. The
method names for mutating patterend fields are named for the type of object,
for example `$api.paths.set-path('/products/{id}', $pathObject)` and
`$api.paths.delete-path('/products/{id}')`.

A `get-path` method is provided as an alias for `AT-KEY`. Where patterned
fields may have a reference value, a `raw-` variant is provided, for example
a `Responses` object could have `$responses.raw-get-response('200')` called,
which would return `Nil` (no such response), a `Response` object, or a
`Reference` object.
