use OpenAPI::Schema::Validate;
use Test;

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        allOf => [
            { type => 'object' },
            { required => ['type'] }
        ]
    });
    ok $schema.validate({ type => 'one' }), 'Object that satisfies all checks accepted';
    throws-like { $schema.validate({ typee => 'one' }) },
    X::OpenAPI::Schema::Validate::Failed, message => /'allOf/2'/,
    'Throws when one of checks is failed in allOf';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
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
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        oneOf => [
            { type => 'string'  },
            { type => 'string'  },
            { type => 'integer' }
        ]
    });
    ok $schema.validate(1), 'oneOf accepted single-matched integer';
    nok $schema.validate('string'), 'oneOf rejected string matched twice';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        not => {
            type => 'string'
        }
    });
    nok $schema.validate('hello'), 'not string rejected string';
    ok $schema.validate(1), 'not string accepted integer';
    ok $schema.validate({}), 'not string accepted object';
}

{
    throws-like { OpenAPI::Schema::Validate.new(schema => { nullable => 'yes' }) },
        X::OpenAPI::Schema::Validate::BadSchema,
        'Having nullable property be an non-boolean is refused (Str)';
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        nullable => True,
        type => 'string'
    });
    ok $schema.validate(Str), 'Type object accepted when nullable is True';
    ok $schema.validate('string'), 'String accepted when nullable is True';
    $schema = OpenAPI::Schema::Validate.new(schema => {
        nullable => False,
        type => 'string'
    });
    ok $schema.validate('string'), 'String accepted when nullable is False';
    nok $schema.validate(Str), 'Type object rejected when nullable is False';

}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'object',
        required => ['username'],
        properties => {
            username => { type => 'string' },
            lastTimeOnline => { readOnly => True, type => 'string' }
        }
    });
    ok $schema.validate({username => 'Zero', lastTimeOnline => 'now'}, :read), 'Property with readOnly accepted when :read';
    nok $schema.validate({username => 'Zero', lastTimeOnline => 'now'}, :write), 'readOnly property rejected when :write';
}

done-testing;
