use Test;
use AttrX::Mooish;

plan 8;

my $inst;

sub make-method( Str $name, &code ) {
    &code.set_name( $name );
    ($name, &code)
}

my class Foo1 {
    has $.bar is mooish( :composer );
    has $.baz is mooish( :composer<baz-compose> );

    method !compose-bar {
        self.^add_method( |make-method("bar-composed", method { "yes, bar is composed!" }) );
    }

    method !baz-compose (*%attr) {
        self.^add_method( |make-method("baz-composed", method { "yes, baz is composed!" }) );
    }
}

ok Foo1.^can('bar-composed'), "bar-composed method exists";
ok Foo1.^can('baz-composed'), "baz-composed method exists";
is Foo1.bar-composed, "yes, bar is composed!", "bar compose works";
is Foo1.baz-composed, "yes, baz is composed!", "baz named compose works";

my role FooRole2 {
    has $.foo is mooish( :composer );

    method !compose-foo {
        self.^add_method( |make-method("foo-composed", method { "foo-composed method" }) );
    }
}

my class Foo2 does FooRole2 {
    has $.bar is mooish( :composer );

    method !compose-bar {
        self.^add_method( |make-method("bar-composed", method { "bar is composed!" }) );
    }
}

ok Foo2.^can('foo-composed'), "foo composed method";
ok Foo2.^can('bar-composed'), "bar composed method";
is Foo2.foo-composed, "foo-composed method", "foo-composed method value";
is Foo2.bar-composed, "bar is composed!", "bar-composed method value";

done-testing;
# vim: ft=perl6
