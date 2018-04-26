use OpenAPI::Schema::Validate;
use Test;

throws-like
    { OpenAPI::Schema::Validate.new(schema => { minProperties => 2.5 }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having minProperties property be an non-integer is refused (Rat)';
throws-like
    { OpenAPI::Schema::Validate.new(schema => { maxProperties => '4' }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having maxProperties property be an non-integer is refused (Str)';
throws-like
    { OpenAPI::Schema::Validate.new(schema => { required => <a a> }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having required property be an non-unique list is refused';

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'object',
        minProperties => 2,
        maxProperties => 4
    });
    nok $schema.validate({a => 1}), 'Object below minimum properties number rejected';
    ok $schema.validate({a => 1, b => 2}), 'Object of minimum properties number rejected';
    ok $schema.validate({a => 1, b => 2, c => 3, d => 4}), 'Object of maximum properties number accepted';
    nok $schema.validate({a => 1, b => 2, c => 3, d => 4, e => 5}), 'Object over maximum properties number rejected';
    nok $schema.validate('string'), 'String instead of array rejected';
    $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'object',
        required => <a b>
    });
    nok $schema.validate({a => 1}), 'Object without required attribute rejected';
    ok $schema.validate({a => 1, b => 2}), 'Object with all required attributes accepted';
    ok $schema.validate({a => 1, b => 2, c => 3}), 'Object that has additional attributes besides required accepted';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'object',
        properties => {
            id => { type => 'integer' },
            name => { type => 'string' }
        },
        maxProperties => 2,
        required => ['name']
    });
    ok $schema.validate({id => 1, name => 'one'}), 'Correct object accepted';
    ok $schema.validate({name => 'one'}), 'Correct object with values not in properties accepted';
    nok $schema.validate({id => 1, name => 2}), 'Object with incorrect schema rejected';
    nok $schema.validate({name => 2}), 'Object with incorrect schema rejected';
    throws-like { $schema.validate({a => 1, b => 2, c => 3}) },
    X::OpenAPI::Schema::Validate::Failed, message => /'more'/,
    'properties check goes after other object checks';
    $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'object',
        properties => { id => { type => 'integer' } },
        additionalProperties => { type => 'string' }
    });
    ok $schema.validate({id => 1, color => 'red'}), 'Correct object with additionalProperties accepted';
    nok $schema.validate({id => 1, color => 1}), 'Incorrect object with additionalProperties rejected';
    $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'object',
        properties => { id => { type => 'integer' } },
        additionalProperties => True
    });
    ok $schema.validate({id => 1, color => 'red'}), 'additionalProperties set to True allows other properties, 1';
    ok $schema.validate({id => 1, color => 1}), 'additionalProperties set to True allows other properties, 2';
    $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'object',
        properties => { id => { type => 'integer' } },
        additionalProperties => False
    });
    ok $schema.validate({id => 1}), 'additionalProperties set to False accepts correct object';
    throws-like $schema.validate({id => 1, color => 'red', text => 'lyrics'}),
    X::OpenAPI::Schema::Validate::Failed, message => /'text'/,
    'additionalProperties set to False rejects other attributes';
    $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'object',
        required => ['id', 'name'],
        properties => { id => {}, name => {}, color => {} },
        additionalProperties => False
    });
    ok $schema.validate({id => 1, name => 'One'}), 'additionalProperties checks a subset, not equality';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'object',
        properties => {
            type => {
                type => 'string',
                enum => <tsun kuu kigai>
            }
        }
    });
    ok $schema.validate({type => 'tsun'}), 'Object with property value from enum accepted';
    nok $schema.validate({type => 'dan'}), 'Object with custom property value rejected';
}

done-testing;
