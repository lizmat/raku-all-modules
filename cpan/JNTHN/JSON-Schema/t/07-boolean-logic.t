use v6;
use Test;
use JSON::Schema;

throws-like { JSON::Schema.new(schema => { allOf => 42 }) },
    X::JSON::Schema::BadSchema,
    'Having allOf property be an integer is refused';
throws-like { JSON::Schema.new(schema => { anyOf => 42 }) },
    X::JSON::Schema::BadSchema,
    'Having anyOf property be an integer is refused';
throws-like { JSON::Schema.new(schema => { oneOf => 42 }) },
    X::JSON::Schema::BadSchema,
    'Having oneOf property be an integer is refused';
throws-like { JSON::Schema.new(schema => { not => 42 }) },
    X::JSON::Schema::BadSchema,
    'Having not property be an integer is refused';

{
    my $schema = JSON::Schema.new(schema => {
        allOf => [
            { type => 'object' },
            { required => ['type'] }
        ]
    });
    ok $schema.validate({ type => 'one' }), 'Object that satisfies all checks accepted';
    throws-like { $schema.validate({ typee => 'one' }) },
    X::JSON::Schema::Failed, message => /'allOf/2'/,
    'Throws when one of checks is failed in allOf';
}

{
    my $schema = JSON::Schema.new(schema => {
        anyOf => [
            { type => 'object' },
            { type => 'string' }
        ]
    });
    ok $schema.validate({}), 'anyOf of object and string accepted object';
    ok $schema.validate('string'), 'anyOf of object and string accepted string';
    nok $schema.validate(1), 'anyOf of object and string rejected integer';
}

{
    my $schema = JSON::Schema.new(schema => {
        oneOf => [
            { type => 'string'  },
            { type => 'string'  },
            { type => 'integer' }
        ]
    });
    ok $schema.validate(1), 'oneOf accepted single-matched integer';
    nok $schema.validate('string'), 'oneOf rejected string matched twice';
    nok $schema.validate(3.5), 'oneOf rejected never matched Rat';
}

{
    my $schema = JSON::Schema.new(schema => {
        not => {
            type => 'string'
        }
    });
    nok $schema.validate('hello'), 'not string rejected string';
    ok $schema.validate(1), 'not string accepted integer';
    ok $schema.validate({}), 'not string accepted object';
}

done-testing;
