use v6;
use Test;

use JSON::Infer;


my @tests = (
   {
      description => 'simple attributes',
      class_name  => 'My::Test',
      value => {
         foo   => 'var',
         baz   => 9,
         yada  => Any,
      },
      classes  => 0,
   },
   {
      description => 'attribute with one object',
      class_name  => 'My::Test',
      value => {
         foo   => 'var',
         baz   => 9,
         yada  => { cart => 'horse'},
      },
      classes  => 1,
   },
   {
      description => 'attribute with more deeply nested object',
      class_name  => 'My::Test',
      value => {
         foo   => 'var',
         baz   => 9,
         yada  => { cart => {type => 'hat'}},
      },
      classes  => 2,
   },
);

for @tests -> $test {
   ok(my $object = JSON::Infer::Class.new-from-data($test<class_name>, $test<value>), "new_from_data " ~ $test<description>);
   isa-ok($object, JSON::Infer::Class);
   like $object.file-path, /\.pm$/, "file-path";
   is($object.name, $test<class_name>, "got the right name");
   is($object.attributes.elems, $test<value>.keys.elems, "got the right number of attributes");
   is($object.classes.elems, $test<classes>, "have " ~ ( $test<classes> > 0 ?? $test<classes> !! 'no' ) ~ " classes");

   for  $test<value>.keys -> $attr {
      ok(my $attr_def = $object.attributes{$attr}, "got attribute $attr");
      isa-ok($attr_def, JSON::Infer::Attribute);
      is($attr_def.class, $object.name, "and the attribute has the right class");
   }

}

done-testing();
# vim: expandtab shiftwidth=4 ft=perl6
