use v6;
use Test;
use JSON::Schema;

throws-like { JSON::Schema.new(schema => { if => 42 }) },
    X::JSON::Schema::BadSchema,
    'Having if property be an integer is refused';
throws-like { JSON::Schema.new(schema => { then => 42 }) },
    X::JSON::Schema::BadSchema,
    'Having then property be an integer is refused';
throws-like { JSON::Schema.new(schema => { else => 42 }) },
    X::JSON::Schema::BadSchema,
    'Having else property be an integer is refused';

my $schema;
{
    $schema = JSON::Schema.new(schema => { then => { type => 'string' }, else => { minimum => 10 } });
    ok $schema.validate(0), 'then and else checks are not applied when `if` is missing';
    $schema = JSON::Schema.new(schema => { # Check length if string, check type otherwise
        if => { type => 'string' },
        then => { minLength => 5 },
        else => { type => 'integer' } });
    ok $schema.validate('123456'), 'then check is passed';
    nok $schema.validate('1234'), 'then check is failed';
    ok $schema.validate(5), 'else check is passed';
    nok $schema.validate(5.0), 'else check is failed';
}

done-testing;
