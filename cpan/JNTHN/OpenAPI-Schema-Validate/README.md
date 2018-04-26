# OpenAPI::Schema::Validate

Validates a value or data structure (of hashes and arrays) against an OpenAPI
schema definition.

## Synopsis

    use OpenAPI::Schema::Validate;

    # A schema should have been deserialized into a hash at the top level.
    # It will have been if you use this with OpenAPI::Model.
    my $schema = OpenAPI::Schema::Validate.new(
        schema => from-json '{ "type": "string" }'
    );

    # Validate it and use the result as a boolean.
    say so $schema.validate("foo");     # True
    say so $schema.validate(42);        # False
    say so $schema.validate(Str);       # False

    # Validate it in sink context; Failure throws if there's a validation
    # error; catch it and us the `reason` property for diagnostics.
    for "foo", 42, Str -> $test {
        $schema.validate($est);
        say "$test.perl() is valid";
        CATCH {
            when X::OpenAPI::Schema::Validate::Failed {
                say "$test.perl() is not valid at $_.path(): $_.reason()";
            }
        }
    }

## Methods

### new(:%schema!, :%formats, :%add-formats)

Constructs a schema validation object, checking the schema for any errors
(for example, properties having the wrong type of value, or `pattern` using
regex syntax beyond that allowed by the OpenAPI specification).

By default, the following values of `format` are recognized and enforced:

* `date-time` (as defined by date-time in RFC3339)
* `date` (as defined by full-date in RFC3339)
* `time` (as defined by full-time in RFC3339)
* `email` (as defined by RFC5322, section 3.4.1)
* `idn-email` (as defined by RFC6531)
* `hostname` (as defined by RFC1034 section 3.1, including host names produced
  using the Punycode algorithm specified in RFC5891 section 4.4)
* `idn-hostname` (as defined by either RFC1034 as for hostname, or an
  internationalized hostname as defined by RFC5890, section 2.3.2.3).
* `ipv4` (an IPv4 address according to the "dotted-quad" ABNF syntax as
  defined in RFC2673 section 3.2)
* `ipv6` (an IPv6 address as defined in RFC4291 section 2.2)
* `uri` (a valid URI as defiend by RFC3986)
* `uri-reference` (a valid URI or relative-reference as defined by RFC3986)
* `iri` (a valid IRI as defined by RFC3987)
* `iri-reference` (a valid IRI or relative-reference as defiend by RFC3987)
* `uri-template` (a valid URI template as defined by RFC6570)
* `json-pointer` (a valid representation of a JSON pointer as defiend by
  RFC6901 section 5)
* `relative-json-pointer` (a valid representation of a `relative-json-pointer`
  as defined by RFC6901)
* `regex` (a valid regex according to the ECMA 262 regular expression dialect)
* `int32` (range check)
* `int64` (range check)
* `binary` (when `string` type and `binary` format are used, then instead of
  checking for `Str`, we check for `Blob`)

All other `format` strings are ignored. However, it is possible to extend the
validator to support additional formats by passing a hash as the `add-formats`
named argument. The keys are the additional format to support, and the value
will be something used in a smartmatch against the value being validated. The
most common choices for this will be `Regex` or a `Block`.

```
    my $schema = OpenAPI::Schema::Validate.new(
        schema => from-json '{ "type": "string" }',
        add-formats => {
            isbn => /^(97(8|9))?\d{9}(\d|X)$/,
            percentage => { 0 <= $_ <= 100 }
        }
    );
```

Passing `formats` allows complete control over the formats that are validated.
To disable all format validation, pass `formats => {}`.

### validate($value, :$read, :$write)

Performs validation of the passed value. Returns `True` if the validation is
successful, and a `Failure` if it is unsuccessful. This allows use in both a
boolean context, or a sink context in which case the failiure will be sunk and
an exception of type `X::OpenAPI::Schema::Validate::Failed` thrown.

OpenAPI schemas may contain the `readOnly` and `writeOnly` properties. These
are used for properties that may only show up in responses and requets
respectively. Thus, pass `:read` when validating a response, and `:write` when
validating a request, in order to allow the appropriate properties to pass (or
fail) validation. If neither of `:read` and `:write` are passed then both
`readOnly` and `writeOnly` will always fail.
