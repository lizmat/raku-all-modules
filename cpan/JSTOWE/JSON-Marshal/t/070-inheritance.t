#!perl6

use v6;
use Test;


use JSON::Marshal;
use JSON::Fast;

class ParentOne {
    has Str $.name = "default";
    has Int $.number;
}

class ChildOne is ParentOne {
    has Str $.name;
}

my $outer = ChildOne.new(name => 'foo', number => 42);

my $ret;

lives-ok { $ret = marshal($outer) }, "marshal object";

my %json = from-json($ret);

is %json<name>, "foo", "got string attribute from child class";
is %json<number>, 42, "got number attribute from child class";

class ParentTwo {
    has Version $.version;

}

class ChildTwo is ParentTwo {
    has Version $.version is marshalled-by(-> Version $v { $v.Str });
}

$outer = ChildTwo.new(version => Version.new("0.0.1"));

lives-ok { $ret = marshal($outer) }, "marshal object";

%json = from-json($ret);

is %json<version>, '0.0.1', "and it got the right custom marshaller";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
