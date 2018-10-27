#!perl6

use v6.c;
use Test;

use JSON::Marshal;
use JSON::Fast;

# test default global behaviour
class SkipTestClassOne {
    has Str $.id;
    has Str $.name;
    has Str %.stuff;
    has Str @.things;
}

my $res-default;

lives-ok { $res-default = marshal(SkipTestClassOne.new(name => "foo"), :skip-null) }, "apply skip-null to marshal";

my $out = from-json($res-default);

nok $out<id>:exists, "and the (null) id was skipped";
nok $out<stuff>:exists, "and the empty stuff was skipped";
nok $out<things>:exists, "and the empty things was skipped";
is  $out<name>, "foo", "but we still got the defined one";

class SkipTestClassTwo {
    has Str $.id is json-skip-null;
    has Str $.rev is json-skip-null;
    has Str $.name;
    has Str $.leave-blank;
    has Str %.empty-hash;
    has Str %.skip-hash is json-skip-null;
}

lives-ok { $res-default = marshal(SkipTestClassTwo.new(name => "foo", rev => "bar")) }, "apply skip-null trait to single attribute";

$out = from-json($res-default);

nok $out<id>:exists, "and the (null) id was skipped";
is  $out<name>, "foo", "but we still got the defined one";
ok $out<leave-blank>:exists, "one not defined but without trait still there";
nok $out<leave-blank>.defined, "and it isn't defined";
is $out<rev>, "bar", "one with the trait but with value is there";
ok $out<empty-hash>:exists, "the empty hash is there";
nok $out<skip-hash>:exists, "the skipped one isn't there";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
