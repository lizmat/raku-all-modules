use v6.c;
use Test;
use Object::Delayed;

plan 8;

my @seen;

class Foo {
    has $.zip = slack { @seen.push("Foo"); "foo" };
}

my $object = Foo.new;
is +@seen, 0, 'no attribute access yet';

# need to use .item to actually make it check the result, rather than type
is $object.zip.item, "foo", "does the attribute give the right value";
is +@seen,               1, "did we access the code once";
is $object.zip.item, "foo", "does the attribute still give the right value";
is +@seen,               1, "did we access the code not again";

@seen = ();
$object = Foo.new(zip => "bar");
is +@seen, 0, 'no attribute access yet';
is $object.zip, "bar", "does the attribute give the right value";
is +@seen, 0, 'still no attribute access yet';

# vim: ft=perl6 expandtab sw=4
