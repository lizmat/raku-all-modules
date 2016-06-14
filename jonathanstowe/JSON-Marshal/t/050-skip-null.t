#!perl6

use v6.c;
use Test;

use JSON::Marshal;
use JSON::Fast;

# test default global behaviour
class SkipTestClassOne {
    has Str $.id;
    has Str $.name;
}

my $res-default;

lives-ok { $res-default = marshal(SkipTestClassOne.new(name => "foo"), :skip-null) }, "apply skip-null to marshal";

my $out = from-json($res-default);

nok $out<id>:exists, "and the (null) id was skipped";
is  $out<name>, "foo", "but we still got the defined one";

class SkipTestClassTwo {
    has Str $.id is json-skip-null;
    has Str $.rev is json-skip-null;
    has Str $.name;
    has Str $.leave-blank;
}

lives-ok { $res-default = marshal(SkipTestClassTwo.new(name => "foo", rev => "bar")) }, "apply skip-null trait to single attribute";

$out = from-json($res-default);

nok $out<id>:exists, "and the (null) id was skipped";
is  $out<name>, "foo", "but we still got the defined one";
ok $out<leave-blank>:exists, "one not defined but without trait still there";
nok $out<leave-blank>.defined, "and it isn't defined";
is $out<rev>, "bar", "one with the trait but with value is there";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
