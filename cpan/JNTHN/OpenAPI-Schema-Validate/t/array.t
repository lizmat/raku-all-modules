use OpenAPI::Schema::Validate;
use Test;

throws-like
    { OpenAPI::Schema::Validate.new(schema => { minItems => 4.5 }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having minItems property be an non-integer is refused (Rat)';
throws-like
    { OpenAPI::Schema::Validate.new(schema => { maxItems => '4' }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having maxItems property be an non-integer is refused (Str)';
throws-like
    { OpenAPI::Schema::Validate.new(schema => { uniqueItems => 'yes' }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having uniqueItems property be an non-boolean is refused (Str)';

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'array',
        minItems => 2,
        maxItems => 4,
        items => { type => 'integer'}
    });
    nok $schema.validate([1]), 'Array below minimum length rejected';
    ok $schema.validate([1,2]), 'Array of minimum length rejected';
    ok $schema.validate([1,2,3,4]), 'Array of maximum length accepted';
    nok $schema.validate([1,2,3,4,5]), 'Array over maximum length rejected';
    nok $schema.validate('string'), 'String instead of array rejected';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'array',
        uniqueItems => False,
        items => { type => 'integer'}
    });
    ok $schema.validate([1, 1]), 'Array with duplicates accepted';
    $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'array',
        uniqueItems => True,
        items => { type => 'object', required => ['a'] }
    });
    ok $schema.validate([{a => 1, b => 2}, {c => 1, a => 1}]), 'Array of objects without duplicates accepted';
    nok $schema.validate([{a => 1, b => 2}, {a => 1, b => 2}]), 'Array of objects with duplicates rejected';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'array',
        items => { type => 'string' },
        maxItems => 3
    });
    ok $schema.validate(['one']), 'Schema with simple type passes';
    throws-like { $schema.validate([1, 1]) },
    X::OpenAPI::Schema::Validate::Failed,
    'Incorrect array values rejected';

    throws-like { $schema.validate([1, 1, 1, 1, 1]) },
    X::OpenAPI::Schema::Validate::Failed, message => /'less'/,
    'items check goes after other array checks';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'array',
        items => { type => 'array', items => { type => 'string' } }
    });
    ok $schema.validate([['one', 'two'], ['three', 'four']]), 'Nested array accepted';
    nok $schema.validate([['one', 1], ['three', 'four']]), 'Incorrect inner array rejected';
    nok $schema.validate([['one', 'two'], 'three']), 'Incorrect outer array rejected';
    throws-like { $schema.validate(['1', 1]) },
    X::OpenAPI::Schema::Validate::Failed, message => /'root/items'/,
    'Path is correct';
}

done-testing;
