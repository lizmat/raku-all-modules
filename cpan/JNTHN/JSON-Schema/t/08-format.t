use v6;
use Test;
use JSON::Schema;

my $schema;
{
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'date-time'
    });
    ok $schema.validate('1996-12-19T16:39:57-08:00'), 'Valid datetime is accepted';
    nok $schema.validate('Tomorrow'), 'Invalid datetime rejected';
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'date'
    });
    ok $schema.validate('1996-12-19'), 'Valid date is accepted';
    nok $schema.validate('Tomorrow'), 'Invalid date rejected';
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'time'
    });
    ok $schema.validate('16:39:57-08:00'), 'Valid relative time accepted';
    nok $schema.validate('half past ten'), 'Invalid relative time rejected';
}

{
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'date-time'
    });
    nok $schema.validate('2017-03-29T23:02:60Z'), 'Invalid date-time by second';
    nok $schema.validate('2017-03-29T23:61:55Z'), 'Invalid date-time by minute';
    nok $schema.validate('2017-03-29T24:02:55Z'), 'Invalid date-time by hour';
    nok $schema.validate('2017-03-32T23:02:55Z'), 'Invalid date-time by day';
    nok $schema.validate('2017-02-30T23:02:55Z'), 'Invalid date-time by February month, 1';
    nok $schema.validate('2017-02-29T23:02:55Z'), 'Invalid date-time by February month, 2';
    nok $schema.validate('2017-13-29T23:02:55Z'), 'Invalid date-time by month';
    nok $schema.validate('2017-03-00T23:02:55Z'), 'Invalid date-time with day 0';
    nok $schema.validate('2017-00-29T23:02:55Z'), 'Invalid date-time by month 0';
    nok $schema.validate("2017-03-29\t23:02:55-12:00"), 'Invalid date-time with tab instead of space';
}

# email, idn-email

# hostname, idn-hostname

{
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'ipv4'
    });
    ok $schema.validate('127.0.0.1'), 'Valid IPv4 accepted';
    nok $schema.validate('127.0.0'), 'Partial IPv4 rejected';
    nok $schema.validate('632.23.53.12'), 'Invalid IPv4 rejected';
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'ipv6'
    });
    ok $schema.validate('1080:0:0:0:8:800:200C:417A'), 'Valid IPv6 accepted';
    nok $schema.validate('1080:0:0:0:8:800:200C'), 'Invalid IPv6 rejected';
}

{
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'uri'
    });
    ok $schema.validate('foo://example.com:8042'), 'Valid URI accepted';
    nok $schema.validate('foo'), 'Invalid URI rejected';
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'uri-reference'
    });
    ok $schema.validate('//example.org/scheme-relative/URI/with/absolute/path/to/resource.'), 'Valid URI Reference accepted';
    nok $schema.validate('\\foo'), 'Invalid URI Reference rejected';
}

# iri, iri-reference

{

    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'uri-template'
    });
    ok $schema.validate('http://www.example.com/{term:1}/{term}/{test*}/foo{?query,number}'), 'Valid URI Template accepted';
    nok $schema.validate('{'), 'Invalid URI Template rejected';
}

{
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'json-pointer'
    });
    ok $schema.validate('/foo/bar'), 'Valid JSON Pointer accepted';
    nok $schema.validate('foo'), 'Invalid JSON Pointer rejected';
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'relative-json-pointer'
    });
    ok $schema.validate('1/foo/bar'), 'Valid relative JSON Pointer accepted';
    nok $schema.validate('foo'), 'Invalid relative JSON Pointer rejected';
}

{
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'regex'
    });
    ok $schema.validate('foo$'), 'Valid regex accepted 1';
    ok $schema.validate('&\w+(foo|bar)'), 'Valid regex accepted 2';
    nok $schema.validate('\a'), 'Invalid regex rejected';
}

{
    $schema = JSON::Schema.new(schema => {
        type => 'string',
        format => 'hello'
    },
    formats => {},
    add-formats => { hello => /^'hello'$/ });
    ok $schema.validate('hello'), 'add-formats format accepted valid input';
    nok $schema.validate('hellou'), 'add-formats format rejected invalid input';
}

done-testing;
