#!perl6
use v6;
use Test;
use lib 'lib';

use JSON::Fast;

use JSON::Infer::Attribute;


my $object = JSON::Infer::Attribute.new();
isa-ok($object, JSON::Infer::Attribute);


my @tests = (
               {
                  attr_name   => 'test_attr',
                  value => 'foo',
                  class => 'My::Test',
                  type_constraint   => 'Str',
                  classes  => 0,
                  is_array  => False,
                  description => 'value is a string',
               },
               {
                  attr_name   => 'test_attr',
                  value => 9,
                  class => 'My::Test',
                  type_constraint   => 'Int',
                  classes  => 0,
                  is_array  => False,
                  description => 'value is a Number',
               },
               {
                  attr_name   => 'test_attr',
                  value => Str,
                  class => 'My::Test',
                  type_constraint   => 'Str',
                  is_array  => False,
                  classes  => 0,
                  description => 'value is undefined',
               },
               {
                  attr_name   => 'test_attr',
                  value => True,
                  class => 'My::Test',
                  type_constraint   => 'Bool',
                  is_array  => False,
                  classes  => 0,
                  description => 'value is a boolean (true)',
               },
               {
                  attr_name   => 'test_attr',
                  value => False,
                  class => 'My::Test',
                  type_constraint   => 'Bool',
                  is_array  => False,
                  classes  => 0,
                  description => 'value is a boolean (false)',
               },
               {
                  attr_name   => 'test_attr',
                  value => ['foo'],
                  class => 'My::Test',
                  type_constraint   => '',
                  is_array  => True,
                  classes  => 0,
                  description => 'value is an Array of strings',
               },
               {
                  attr_name   => 'test_attr',
                  value => { test_attr => 'foo' },
                  class => 'My::Test',
                  type_constraint   => 'TestAttr',
                  classes  => 1,
                  is_array  => False,
                  description => 'value is an object',
               },
               {
                  attr_name   => 'test_attr',
                  value => { test_attr => 'foo', 'class_attr' => { foo => 9 } },
                  class => 'My::Test',
                  type_constraint   => 'TestAttr',
                  classes  => 2,
                  is_array  => False,
                  description => 'value is an object with an object attribute',
               },
               {
                  attr_name   => 'test_attr',
                  value => [{ test_attr => 'foo' },],
                  class => 'My::Test',
                  type_constraint   => 'TestAttr',
                  is_array  => True,
                  classes  => 1,
                  description => 'value is an an array of object',
               },
            );


for @tests -> $test {
   ok(my $object = JSON::Infer::Attribute.new-from-value( $test<attr_name>, $test<value>, $test<class>), "new-from-value " ~ $test<description>);

   isa-ok($object, JSON::Infer::Attribute);
   is( $object.name, $test<attr_name>, "got the right name" );
   is($object.is-array, $test<is_array>, "now it's multiplicity right");
   is($object.sigil, $test<is_array> ?? '@' !! '$', "and the right sigil");
   is( $object.type-constraint, $test<type_constraint>, "got the right type constraint" );
   is( $object.classes.elems , $test<classes>, "and " ~ ( $test<classes> > 0 ?? $test<classes> !! 'no' ) ~ ' classes' );
}


done-testing();

# vim: expandtab shiftwidth=4 ft=perl6
