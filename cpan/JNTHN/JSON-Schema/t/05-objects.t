use v6;
use Test;
use JSON::Schema;

my $schema;

throws-like
    { JSON::Schema.new(schema => { minProperties => 2.5 }) },
    X::JSON::Schema::BadSchema,
    'Having minProperties property be an non-integer is refused (Rat)';
throws-like
    { JSON::Schema.new(schema => { maxProperties => '4' }) },
    X::JSON::Schema::BadSchema,
    'Having maxProperties property be an non-integer is refused (Str)';
throws-like
    { JSON::Schema.new(schema => { required => ('a', 'a') }) },
    X::JSON::Schema::BadSchema,
    'Having required property be an non-unique list is refused';

{
    $schema = JSON::Schema.new(schema => {
        type => 'object',
        minProperties => 2,
        maxProperties => 4
    });
    nok $schema.validate({a => 1}), 'Object below minimum properties number rejected';
    ok $schema.validate({a => 1, b => 2}), 'Object of minimum properties number rejected';
    ok $schema.validate({a => 1, b => 2, c => 3, d => 4}), 'Object of maximum properties number accepted';
    nok $schema.validate({a => 1, b => 2, c => 3, d => 4, e => 5}), 'Object over maximum properties number rejected';
    nok $schema.validate('string'), 'String instead of object rejected';
    $schema = JSON::Schema.new(schema => {
        type => 'object',
        required => <a b>
    });
    throws-like $schema.validate({}), X::JSON::Schema::Failed, message => /\'a\' ', ' \'b\'/;
    nok $schema.validate({a => 1}), 'Object without required attribute rejected';
    ok $schema.validate({a => 1, b => 2}), 'Object with all required attributes accepted';
    ok $schema.validate({a => 1, b => 2, c => 3}), 'Object that has additional attributes besides required accepted';
}

throws-like
    { JSON::Schema.new(schema => { properties => list }) },
    X::JSON::Schema::BadSchema,
    'Having properties property be an empty list is refused';
throws-like
    { JSON::Schema.new(schema => { properties => { foo => 1 } }) },
    X::JSON::Schema::BadSchema,
    'Having properties property value be non-object is refused';

{
    $schema = JSON::Schema.new(schema => {
        type => 'object',
        properties => {
            id => { type => 'integer' },
            name => { type => 'string' }
        }
    });
    ok $schema.validate({id => 1, name => 'one'}), 'Correct object accepted';
    ok $schema.validate({name => 'one'}), 'Correct object with values not in properties accepted';
    nok $schema.validate({id => 1, name => 2}), 'Object with incorrect schema rejected';
    nok $schema.validate({name => 2}), 'Object with incorrect schema rejected';
}

{
    $schema = JSON::Schema.new(schema => {
        patternProperties => {
           '^foo\w+' => { type => 'string' },
            '\w+bar$' => { type => 'number' }
        }
    });
    subtest {
        ok $schema.validate(5), 'Validation against patternProperties with primitive type value always succeeds';
        ok $schema.validate({foo => 1}), 'Property not matched with patternProperties rule is accepted';
        ok $schema.validate({fooo => 'foo'}), 'Property matched with patternProperties is accepted';
        nok $schema.validate({fooo => 1}), 'Property matched with patternProperties is rejected';
        nok $schema.validate({fooo => 1, foobar => 5.5}), 'Properties matched with patternProperties are rejected 1';
        nok $schema.validate({fooo => 1, foobar => 1}), 'Properties matched with patternProperties are rejected 2';
        ok $schema.validate({fooo => 'foo', obar => 5.5}), 'Two patterns are matched';
        nok $schema.validate({fooo => 'foo', obar => 5}), 'Incorrect data for one of many patterns in patternProperties is rejected';
    }, 'patternProperties are matched';
}

throws-like
    { JSON::Schema.new(schema => { additionalProperties => 2.5 }) },
    X::JSON::Schema::BadSchema,
    'Having minProperties property be a non-object is refused (Rat)';

{
    $schema = JSON::Schema.new(schema => {
        properties => {
            name => { type => 'string' },
            id => { type => 'integer' }
        },
        patternProperties => {
           '^foo$' => { type => 'string' },
        },
        additionalProperties => {
            type => 'number'
        }
    });
    ok $schema.validate({add1 => 1.0, add2 => 2.0}), 'Additional properties are accepted';
    nok $schema.validate({add1 => 'add2', add2 => 2.0}), 'Additional properties are rejected';
    ok $schema.validate({name => 'name', add1 => 1.0}), 'Additional properties do not interfere with named';
    ok $schema.validate({foo => 'foo', add1 => 1.0}), 'Additional properties do not interfere with patterned';
    ok $schema.validate({name => 'name', foo => 'foo', add1 => 1.0}), 'Additional properties do not interfere with named and patterned';
}

{
    $schema = JSON::Schema.new(schema => {
        properties => {
            name => { type => 'string' }
        },
        additionalProperties => False
    });
    ok $schema.validate({name => "foo"}), 'Valid property is accepted';
    nok $schema.validate({name => "foo", bar => 2}), 'Additional property is rejected';
}

throws-like
    { JSON::Schema.new(schema => { dependencies => 2.5 }) },
    X::JSON::Schema::BadSchema,
    'Having dependencies property be a non-object is refused (Rat)';
throws-like
    { JSON::Schema.new(schema => { dependencies => { a => 1 } }) },
    X::JSON::Schema::BadSchema,
    'Having dependencies property value be non-object is refused (Int)';
throws-like
    { JSON::Schema.new(schema => { dependencies => { a => ('foo', 1) } }) },
    X::JSON::Schema::BadSchema,
    'Having dependencies property value in array form with non-string inside is refused (Int)';

{
    $schema = JSON::Schema.new(schema => {
        dependencies => {
            name => { minProperties => 3 }
        }
    });
    ok $schema.validate(5), 'dependencies property is not checked when value is not an object (Int)';
    ok $schema.validate({name => 'hello', foo => 1, bar => 3}), 'Correct dependant value is accepted';
    nok $schema.validate({name => 'hello'}), 'Incorrect dependant value is rejected';
    ok $schema.validate({foo => 'bar'}), 'dependencies property is not checked when absent';
    $schema = JSON::Schema.new(schema => {
        dependencies => {
            name => ('surname', 'age')
        }
    });
    ok $schema.validate({name => 'hello', surname => 1, age => 1}), 'Required values by dependency array are accepted';
    nok $schema.validate({name => 'hello'}), 'Object with missing dependant properties is rejected';
    ok $schema.validate({foo => 'bar'}), 'dependencies property is not checked when absent';
}

throws-like
    { JSON::Schema.new(schema => { propertyNames => -1 }) },
    X::JSON::Schema::BadSchema,
    'Having propertyNames property be a non-object is refused (Int)';

throws-like
    { JSON::Schema.new(schema => { patternProperties => { one => 1, two => {}, three => True, four => 'hai' } }) },
    X::JSON::Schema::BadSchema,
    'Having patternProperties property have non JSON Schema values is refused';

{
    $schema = JSON::Schema.new(schema => {
        propertyNames => {
            minLength => 5,
            pattern => '^foo'
        }
    });
    ok $schema.validate(5), 'dependencies property is not checked when value is not an object (Int)';
    ok $schema.validate({foobar => 1, foobaz => 2}), 'Object properties with valid names are accepted';
    nok $schema.validate({foo => 1}), 'Object property with too short name is rejected';
    nok $schema.validate({barbarbug => 1}), 'Object property with name out of pattern is rejected';
}

done-testing;
