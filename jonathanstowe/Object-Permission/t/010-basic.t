#!perl6

use v6;
use lib 'lib';
use Test;

use Object::Permission;

my Object::Permission::User $opu;

lives-ok { $opu = Object::Permission::User.new }, "get (type punned) Object::Permission::User";

lives-ok { $*AUTH-USER = $opu }, 'set $*AUTH-USER ok';
throws-like { $*AUTH-USER = "foo" }, X::TypeCheck::Binding, "throws when it gets an exception";
isa-ok $*AUTH-USER, $opu.WHAT, "got the right thing back";

done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
