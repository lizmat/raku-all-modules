#!perl6

use v6;
use lib 'lib';
use Test;

use Object::Permission;

class Foo {
   method test-one() returns Str is authorised-by('test-1-ok') {
       "test-one";
   }

   method test-two()  returns Str is authorised-by('test-2-notok') {
       "test-two";
   }
}

my $foo = Foo.new;

$*AUTH-USER = Object::Permission::User.new(permissions => <test-1-ok>);


my $ret;
lives-ok { $ret = $foo.test-one() }, "okay for method we have permission for";
is $ret, "test-one", "sanity check we got something back";
throws-like { $foo.test-two() }, X::NotAuthorised, permission => 'test-2-notok', "throws for the other one";

$*AUTH-USER.permissions.push('test-2-notok');
lives-ok { $ret = $foo.test-two() }, "okay for method we have just add the permission for";
is $ret, "test-two", "sanity check we got something back";

# rw method tests

class Bar {
    has $!test-rw-one = "test-one-init";

    method test-rw-one() is rw is authorised-by('test-1-ok') {
        $!test-rw-one;
    }

    has $!test-rw-two = "test-two-init";
    method test-rw-two() is rw is authorised-by('test-2-notok') {
        $!test-rw-two;
    }
}

my $bar = Bar.new;

# reset the user for simplicity
$*AUTH-USER = Object::Permission::User.new(permissions => <test-1-ok>);

lives-ok { $bar.test-rw-one = "test-one-set" }, "rw method okay";
is $bar.test-rw-one, "test-one-set", "and it actually got set";

throws-like { $bar.test-rw-two = "test-two-set" }, X::NotAuthorised, "rw method without the permission";

# need to set the permission to check it from here.
$*AUTH-USER.permissions.push('test-2-notok');
is $bar.test-rw-two, "test-two-init", "and the value didn't get set";

# arguments
class Baz {
   method test-one(Str $arg) returns Str is authorised-by('test-1-ok') {
       $arg;
   }

   method test-two(Str $arg)  returns Str is authorised-by('test-2-notok') {
       $arg;
   }
}

my $baz = Baz.new;

$*AUTH-USER = Object::Permission::User.new(permissions => <test-1-ok>);


lives-ok { $ret = $baz.test-one('test-one') }, "okay for method we have permission for with argument";
is $ret, "test-one", "sanity check we got something back";
throws-like { $baz.test-two() }, X::NotAuthorised, permission => 'test-2-notok', "throws for the other one";

$*AUTH-USER.permissions.push('test-2-notok');
lives-ok { $ret = $baz.test-two('test-two') }, "okay for method we have just add the permission for with an argument";
is $ret, "test-two", "sanity check we got something back";

done-testing;

# vim: expandtab shiftwidth=4 ft=perl6
