use v6;
use Test;
use JSON::Schema;

throws-like
    { JSON::Schema.new(schema => { items => 4.5 }) },
    X::JSON::Schema::BadSchema,
    'Having items property be an integer is refused';
throws-like
    { JSON::Schema.new(schema => { items => (1, 2, 3) }) },
    X::JSON::Schema::BadSchema,
    'Having items property be a non-object array is refused';
lives-ok { JSON::Schema.new(schema => { items => {} }) },
    'Having items property be hash is accepted';
lives-ok { JSON::Schema.new(schema => { items => [{}, {}] }) },
    'Having items property be array of hashes is accepted';

my $schema;
{
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        items => { type => 'object' }
    });
    ok $schema.validate('Foo'), 'items property is ignored if not an explicit array type';
    $schema = JSON::Schema.new(schema => { items => { type => 'object' } });
    ok $schema.validate('Foo'), 'items property is ignored if not an explicit array type';
}

{
    $schema = JSON::Schema.new(schema => {
        items => { type => 'integer' }
    });
    ok $schema.validate((1, 2, 3).List), 'array items type restriction for integer accepts list of integers';
    nok $schema.validate((1, 2, 3.14).List), 'array items type restriction for integer rejects list with non-integer element';
    $schema = JSON::Schema.new(schema => {
        items => { type => 'integer', minimum => 0 }
    });
    ok $schema.validate((1, 2, 3).List), 'array items check with two rules accepts correct input';
    nok $schema.validate((1, 2, 3.14).List), 'array items check with two rejects incorrect input by first check';
    nok $schema.validate((1, 2, -3).List), 'array items check with two rejects incorrect input by second check';
}

{
    $schema = JSON::Schema.new(schema => {
        items => ({ type => 'integer' }, { type => 'string'}, { type => 'number' })
    });
    ok $schema.validate((1, 'hello', 3.14).List), 'items property with array value accepts correct input';
    nok $schema.validate((1, 2, 3.14).List), 'items property with array value rejects incorrect input';
    ok $schema.validate((1, 'hello', -3.14, 'world', Nil).List), 'array values after items schemes array length are always accepted 1';
    ok $schema.validate((1, 'hello', -3.14, Nil, 'world').List), 'array values after items schemes array length are always accepted 2';
}

throws-like
    { JSON::Schema.new(schema => { additionalItems => 4.5 }) },
    X::JSON::Schema::BadSchema,
    'Having additionalItems property be a non-object is refused (Rat)';

{
    $schema = JSON::Schema.new(schema => { additionalItems => { type => 'string' } });
    ok $schema.validate((1, 2, 3).List), 'additionalItems property without items property is omitted';
    $schema = JSON::Schema.new(schema => { items => { type => 'integer' }, additionalItems => { type => 'string' } });
    ok $schema.validate((1, 2, 3).List), 'additionalItems property without items property being array os schemas is omitted';
    $schema = JSON::Schema.new(schema => {
        items => ({ type => 'integer' }, { type => 'string' }), additionalItems => { type => 'number' }
    });
    ok $schema.validate((1, 'one', 2.0, 3.0, 4.0).List), 'additionalItems accept correct input';
    nok $schema.validate((1, 'one', 2.0, 3.0, 'four').List), 'additionalItems rejects incorrect input';
}

throws-like
    { JSON::Schema.new(schema => { minItems => 4.5 }) },
    X::JSON::Schema::BadSchema,
    'Having minItems property be a non-integer is refused (Rat)';
throws-like
    { JSON::Schema.new(schema => { maxItems => -1 }) },
    X::JSON::Schema::BadSchema,
    'Having maxItems property be a nagative integer is refused';
throws-like
    { JSON::Schema.new(schema => { minItems => -1 }) },
    X::JSON::Schema::BadSchema,
    'Having minItems property be a negative integer is refused';
throws-like
    { JSON::Schema.new(schema => { maxItems => '4' }) },
    X::JSON::Schema::BadSchema,
    'Having maxItems property be a non-integer is refused (Str)';
throws-like
    { JSON::Schema.new(schema => { uniqueItems => 'yes' }) },
    X::JSON::Schema::BadSchema,
    'Having uniqueItems property be a non-boolean is refused (Str)';

{
    $schema = JSON::Schema.new(schema => {
        type => 'array',
        minItems => 2,
        maxItems => 4
    });
    nok $schema.validate([1]), 'Array below minimum length rejected';
    ok $schema.validate([1,2]), 'Array of minimum length rejected';
    ok $schema.validate([1,2,3,4]), 'Array of maximum length accepted';
    nok $schema.validate([1,2,3,4,5]), 'Array over maximum length rejected';
    nok $schema.validate('string'), 'String instead of array rejected';
}

throws-like
    { JSON::Schema.new(schema => { uniqueItems => 4.5 }) },
    X::JSON::Schema::BadSchema,
    'Having uniqueItems property be an integer is refused';

{
    $schema = JSON::Schema.new(schema => {
        type => 'array',
        uniqueItems => False
    });
    ok $schema.validate([1, 1]), 'Array with duplicates accepted';
    $schema = JSON::Schema.new(schema => {
        type => 'array',
        uniqueItems => True
    });
    ok $schema.validate([{a => 1, b => 2}, {c => 1, a => 1}]), 'Array of objects without duplicates accepted';
    nok $schema.validate([{a => 1, b => 2}, {a => 1, b => 2}]), 'Array of objects with duplicates rejected';
}

{
    $schema = JSON::Schema.new(schema => {
        contains => { type => 'integer', minimum => 0 }
    });
    nok $schema.validate(list), 'Empty array does not contain needed element';
    nok $schema.validate((-1).List), 'contains check for positive integer rejects negative integer';
    nok $schema.validate(('hello', 'foo')), 'contains check for positive integer rejects array of strings';
    ok $schema.validate(('hello', 1, 'foo')), 'contains check for positive integer accepts array of strings with `1` included';
}

done-testing;
