use Test;
use AttrX::Mooish;

my $author-testing = ? %*ENV<AUTHOR_TESTING>;

class Foo {
    has $.a is rw is mooish(:clearer, :lazy, :init-arg<a1 a2>);
    has $.n is mooish(:lazy, :init-arg<n1>, :no-init);

    method build-a {
        42
    }

    method build-n {
        "Це - Відповідь!"
    }
}

class Bar is Foo {
}

role FooRole {
    has $.a is rw is mooish(:clearer, :lazy, :aliases<a1 a2>);
    has $.n is mooish(:lazy, :no-init);

    method build-a {
        42
    }

    method build-n {
        "Це - Відповідь!"
    }
}

class Baz does FooRole { }
class Fubar is Baz { }

my $inst;

my @t =
    { type => Foo,      name => "class itself" },
    { type => Bar,      name => "inheriting class" },
    { type => Baz,      name => "from role" },
    { type => Fubar,    name => "inheriting from a class with role" },
    ;

plan @t.elems;

for @t -> %data {
    subtest %data<name>, {
        plan 13;
        my \type = %data<type>;
        $inst = type.new( a => pi, n => "невірна відповідь" );
        is $inst.a, pi, "name itself";
        is $inst.a1, pi, "access via alias 1";
        is $inst.a2, pi, "access via alias 2";
        is $inst.n, "Це - Відповідь!", "no-init ignores constructor";

        $inst.a2 = pi*2;
        is $inst.a, pi*2, "manual set via alias";

        $inst.clear-a;
        is $inst.a, 42, "clearing initializes from builder";

        $inst.a = -42;
        $inst.clear-a1;
        is $inst.a, 42, "clearing of alias initializes from builder";

        $inst = type.new( a1 => pi/2, n1 => "все-одно невірно" );
        is $inst.a, pi/2, "via first alias";
        is $inst.n, "Це - Відповідь!", "no-init ignores aliased parameter too";

        $inst = type.new( a2 => pi/3 );
        is $inst.a, pi/3, "via second alias";

        $inst = type.new( a => -42, a2 => pi, a1 => e );
        is $inst.a, -42, "attribute name wins against aliases";

        $inst = type.new( a2 => pi, a1 => e );
        is $inst.a, e, "first defined alias wins when no argument name";

        $inst = type.new();
        is $inst.a, 42, "builder works for aliased attributes, as usual";
    }
}

done-testing;

# vim: ft=perl6
