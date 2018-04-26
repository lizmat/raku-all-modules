use OpenAPI::Schema::Validate;
use Test;

throws-like
    { OpenAPI::Schema::Validate.new(schema => { minLength => 4.5 }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having minLength property be an non-integer is refused (Rat)';
throws-like
    { OpenAPI::Schema::Validate.new(schema => { minLength => '4' }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having minLength property be an non-integer is refused (Str)';

throws-like
    { OpenAPI::Schema::Validate.new(schema => { maxLength => 4.5 }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having maxLength property be an non-integer is refused (Rat)';
throws-like
    { OpenAPI::Schema::Validate.new(schema => { maxLength => '4' }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having maxLength property be an non-integer is refused (Str)';

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        minLength => 5,
        maxLength => 10
    });
    ok $schema.validate('hello'), 'String of minimum length is ok';
    nok $schema.validate('hell'), 'String below minimum length rejected';
    ok $schema.validate('hellohello'), 'String of maximum length is ok';
    nok $schema.validate('hellohello!'), 'String over maximum length rejected';
    ok $schema.validate('hello!!'), 'String between minimum and maximum ok';
}

done-testing;
