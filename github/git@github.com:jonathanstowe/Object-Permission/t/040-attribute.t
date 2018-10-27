#!perl6

use v6;
use lib 'lib';
use Test;

use Object::Permission;

class Foo {
    has Str $.test-one is authorised-by('test-1-ok') = "test-one";
    has Str $.test-two is authorised-by('test-2-notok') = "test-two";
}

my $foo = Foo.new;

$*AUTH-USER = Object::Permission::User.new(permissions => <test-1-ok>);

my $ret;
lives-ok { $ret = $foo.test-one }, "okay for attribute we have permission for";
is $ret, "test-one", "sanity check we got something back";
throws-like { $foo.test-two }, X::NotAuthorised, permission => 'test-2-notok', "throws for the other one";

$*AUTH-USER.permissions.push('test-2-notok');
lives-ok { $ret = $foo.test-two }, "okay for attribute we have just add the permission for";
is $ret, "test-two", "sanity check we got something back";

# rw attribute tests

class Bar {

    has $.test-rw-one is rw is authorised-by('test-1-ok') = "test-one-init";

    has $.test-rw-two is rw is authorised-by('test-2-notok') = "test-two-init";
}

my $bar = Bar.new;

# reset the user for simplicity
$*AUTH-USER = Object::Permission::User.new(permissions => <test-1-ok>);

lives-ok { $bar.test-rw-one = "test-one-set" }, "rw attribute okay";
is $bar.test-rw-one, "test-one-set", "and it actually got set";

throws-like { $bar.test-rw-two = "test-two-set" }, X::NotAuthorised, "rw attribute without the permission";

# need to set the permission to check it from here.
$*AUTH-USER.permissions.push('test-2-notok');
is $bar.test-rw-two, "test-two-init", "and the value didn't get set";

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
