use OpenAPI::Schema::Validate;
use Test;

throws-like
    { OpenAPI::Schema::Validate.new(schema => { type => 'string', pattern => 42 }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having pattern property be an non-string is refused (Int)';
throws-like
    { OpenAPI::Schema::Validate.new(schema => { type => 'string', pattern => {} }) },
    X::OpenAPI::Schema::Validate::BadSchema,
    'Having pattern property be an non-string is refused (Hash)';

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '^\d+$'
    });
    ok $schema.validate('1'), 'String matching ^\d+$ validates (1)';
    ok $schema.validate('2901'), 'String matching ^\d+$ validates (2)';
    nok $schema.validate('a12b'), 'String not matching ^\d+$ is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => 'a|b'
    });
    ok $schema.validate('rad'), 'String matching a|b validates (1)';
    ok $schema.validate('best'), 'String matching a|b validates (2)';
    nok $schema.validate('oops'), 'String not matching a|b is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '\bass\b'
    });
    ok $schema.validate('kicks ass'), 'String matching \bass\b validates';
    nok $schema.validate('classic'), 'String not matching \bass\b is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '^(?=a|b)\w+$'
    });
    ok $schema.validate('add'), 'String matching ^(?=a|b)\w+$ validates (1)';
    ok $schema.validate('best'), 'String matching ^(?=a|b)\w+$ validates (2)';
    nok $schema.validate('oops'), 'String not matching ^(?=a|b)\w+$ is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '^(?!0)\d+$'
    });
    ok $schema.validate('100'), 'String matching ^(?!0)\d+$ validates';
    nok $schema.validate('0100'), 'String not matching ^(?!0)\d+$ is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '^\d*?9$'
    });
    ok $schema.validate('12349'), 'String matching ^\d*?9$ validates (1)';
    ok $schema.validate('9'), 'String matching ^\d*?9$ validates (2)';
    nok $schema.validate('123'), 'String not matching ^\d*?9$ is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '^a{2}b{3,}c{1,4}$'
    });
    ok $schema.validate('aabbbc'), 'String matching ^a{2}b{3,}c{1,4}$ validates (1)';
    ok $schema.validate('aabbbbccc'), 'String matching ^a{2}b{3,}c{1,4}$ validates (2)';
    nok $schema.validate('abbbc'), 'String not matching ^a{2}b{3,}c{1,4}$ is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '^.(\w)(?:\d+)$'
    });
    ok $schema.validate('*a1'), 'String matching ^.(\w)(?:\d+)$ validates';
    nok $schema.validate('*aa'), 'String not matching ^.(\w)(?:\d+)$ is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '(\w)\1'
    });
    ok $schema.validate('bookkeeper'), 'String matching (\w)\1 validates';
    nok $schema.validate('nope'), 'String not matching (\w)\1 is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '\t\n'
    });
    ok $schema.validate("\t\n"), 'String matching \t\n validates';
    nok $schema.validate('nope'), 'String not matching \t\n is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '\\\\'
    });
    ok $schema.validate('a\\b'), 'String matching \\\\ validates';
    nok $schema.validate('nope'), 'String not matching \\\\ is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '\x61'
    });
    ok $schema.validate('a'), 'String matching \x61 validates';
    nok $schema.validate('nope'), 'String not matching \x61 is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '[abc]+'
    });
    ok $schema.validate('bbc'), 'String matching [abc]+ validates';
    nok $schema.validate('nope'), 'String not matching [abc]+ is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '[^open]+'
    });
    ok $schema.validate('bbc'), 'String matching [^open]+ validates';
    nok $schema.validate('nope'), 'String not matching [^open]+ is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '[A-Fa-f]+'
    });
    ok $schema.validate('bBc'), 'String matching [A-Fa-f]+ validates';
    nok $schema.validate('no'), 'String not matching [A-fa-f]+ is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '[-]{2}'
    });
    ok $schema.validate('--'), 'String matching [-]{2} validates';
    nok $schema.validate('x'), 'String not matching [-]{2} is invalid';
}

{
    my $schema = OpenAPI::Schema::Validate.new(schema => {
        type => 'string',
        pattern => '^[\d.]+$'
    });
    ok $schema.validate('1.5'), 'String matching ^[\d.]+$ validates';
    nok $schema.validate('x'), 'String not matching ^[\d.]+$ is invalid';
}

done-testing;
