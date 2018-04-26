use OpenAPI::Schema::Validate;
use Test;

throws-like
    { OpenAPI::Schema::Validate.new(schema => { type => 42 }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having type property be an integer is refused';
throws-like
    { OpenAPI::Schema::Validate.new(schema => { type => 'zombie' }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having type property be an invalid type is refused';

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string'
    });
    ok $schema.validate('hello'), 'Simple string validation accepts a string';
    nok $schema.validate(42), 'Simple string validation rejects an integer';
    nok $schema.validate(Any), 'Simple string validation rejects a type object';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'number'
    });
    ok $schema.validate(42.0), 'Simple number validation accepts a Rat';
    ok $schema.validate(42), 'Simple number validation accepts an Int';
    ok $schema.validate(42.5e2), 'Simple number validation accepts a Num';
    nok $schema.validate('hello'), 'Simple number validation rejects a string';
    nok $schema.validate(Any), 'Simple number validation rejects a type object';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'integer'
    });
    ok $schema.validate(42), 'Simple integer validation accepts an integer';
    nok $schema.validate(42.0), 'Simple integer validation rejects a Rat';
    nok $schema.validate('hello'), 'Simple integer validation rejects a string';
    nok $schema.validate(Any), 'Simple integer validation rejects a type object';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'boolean'
    });
    ok $schema.validate(True), 'Simple boolean validation accepts an boolean';
    nok $schema.validate('hello'), 'Simple boolean validation rejects a string';
    nok $schema.validate(Any), 'Simple boolean validation rejects a type object';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'array',
        items => { type => 'integer' }
    });
    ok $schema.validate([42]), 'Simple array validation accepts a Positional';
    nok $schema.validate('hello'), 'Simple array validation rejects a string';
    nok $schema.validate(Any), 'Simple array validation rejects a type object';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'object'
    });
    ok $schema.validate({foo => 'bar'}), 'Simple object validation accepts a Hash';
    nok $schema.validate('hello'), 'Simple object validation rejects a string';
    nok $schema.validate(Any), 'Simple object validation rejects a type object';
}

done-testing;
