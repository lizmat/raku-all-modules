use Test;
use AttrX::Mooish;

plan 6;

my $author-testing = ? %*ENV<AUTHOR_TESTING>;

my %inst-records;

subtest "Inheritance basics", {
    plan 16;
    my $inst;

    class Bar1 {
        has $.initial is default(pi);
        has $.bar is rw is mooish(:lazy, :clearer, :predicate);
        has Int $.build-count = 0;
        submethod TWEAK (|) { %inst-records{self.WHICH} = True; }
        submethod DESTROY { %inst-records{self.WHICH}:delete; }
        method build-bar { $!build-count++; $!initial }
        method direct-access { $!bar }
    };

    my class Foo1 is Bar1 {
        has $.fu;
    }

    $inst = Foo1.new;
    is $inst.bar, pi, "initialized by builder via accessor";

    my $inst2 = Foo1.new;
    is $inst2.direct-access, pi, "initialized by builder via direct access";

    $inst.bar = "foo-bar-baz";
    is $inst.bar, "foo-bar-baz", "set manually ok";
    is $inst2.bar, pi, "second object attribute unchanged";

    if $author-testing {
        # So far, two object, one lazy attribute was initialized per each object.
        is mooish-obj-count, 2, "2 used slots correspond to attribute count";
    }
    else {
        skip "author testing only", 1;
    }

    $inst = Foo1.new;
    for 1..2000 {
        my $v = $inst.bar;
    }
    is $inst.build-count, 1, "attribute build is executed only once";
    if $author-testing {
        is mooish-obj-count, 3, "3 used slots correspond to attribute count";

        for 1..20000 {
            $inst = Foo1.new;
            my $v = $inst.bar;
        }

        is mooish-obj-count, %inst-records.keys.elems, "used slots correspond to number of objects survived GC";
    }
    else {
        skip "author testing only", 2;
    }

    $inst.bar = "something different";
    is $inst.bar, "something different", "set before clear";
    $inst.clear-bar;
    is $inst.has-bar, False, "prefix reports no value";
    is $inst.bar, pi, "cleared and re-initialized";
    is $inst.has-bar, True, "prefix reports a value";

    class Bar2 {
        has $.bar is rw is mooish(:lazy, :clearer);
        has $.baz is rw;

        method build-bar { "not from new" }
    }

    my class Foo2 is Bar2 { }

    $inst = Foo2.new( bar => "from new",  baz => "from NEW" );
    is $inst.baz, "from NEW", "set from constructor";
    is $inst.bar, "from new", "set from constructor";
    $inst.clear-bar;
    is $inst.bar, "not from new", "reset and set not from constructor parameters";

    class Bar3 {
        has $.bar is mooish(:lazy, builder => 'init-bar');
        method init-bar { "from init-bar" }
    }

    my class Foo3 is Bar3 {}

    $inst = Foo3.new;
    is $inst.bar, "from init-bar", "named builder works";
}

subtest "Overriding", {
    my $inst;

    # Base BarN classes from the previous test are used

    my class Foo1 is Bar1 {
        method build-bar {
            callsame;
            "but my string"
        }
    }

    $inst = Foo1.new;
    is $inst.bar, "but my string", "builder overridden";

    my class Foo3 is Bar3 {
        method init-bar { (callsame) ~ " with my suffix" }
    }

    $inst = Foo3.new;
    is $inst.bar, "from init-bar with my suffix", "named builder overridden";
}

subtest "Private", {
    plan 1;
    my $inst;

    my class Foo1 {
        has $!bar is mooish(:lazy);

        method !build-bar { "private value" }

        method get-bar { $!bar }
    }

    my class Foo2 is Foo1 {
        method run-test {
            is self.get-bar, "private value", "private attribute from parent class";
        }
    }

    $inst = Foo2.new;
    $inst.run-test;
}

subtest "Chained", {
    plan 10;
    my $inst;

    my class Foo0 {
        has $.foo0;
    }

    my class Foo1 is Foo0 {
        has $.skip-trigger is rw = True;
        has $.foo1 is rw is mooish(:lazy, :clearer, :predicate, :trigger);
        has $!foo2 is mooish(:lazy);
        has $.foo3 is mooish(:lazy('setup-foo3'));

        method build-foo1 { "Foo1::foo1" };
        method trigger-foo1 ( $val, :$constructor = False ) { return if $.skip-trigger || $constructor; is $val, "manual foo1", "trigger on Foo1::foo1" }
        method !build-foo2 { "Foo1::foo2" };
        method get-foo2 { $!foo2 }
        method set-foo2 ( $val) { $!foo2 = $val }
        method setup-foo3 { "Foo1::foo3" }
    }

    my class Bar1 is Foo1 {
        has $.bar1 is mooish(:lazy(-> $,*% {"Bar1::bar1"}));
        has $.bar2 is rw is mooish(:filter);
        method BUILDALL (|) { nextsame } # A BUILDALL may break things sometime

        method filter-bar2 ( $val ) { "filtered-bar2({$val})" }
    }

    my class Baz1 is Bar1 {
        has $.baz1 is mooish(:lazy("init-baz1"));

        method init-baz1 { "Baz1::baz1" }
        method setup-foo3 { "Baz1::foo3" }
    }

    $inst = Baz1.new;
    is $inst.foo1, "Foo1::foo1", "\$.foo1 lazy init";
    is $inst.get-foo2, "Foo1::foo2", "private \$!foo2 lazy init";
    is $inst.foo3, "Baz1::foo3", "overriden \$.foo3 lazy init";
    $inst.skip-trigger = False;
    $inst.foo1 = "manual foo1";
    $inst.skip-trigger = True;
    is $inst.bar1, "Bar1::bar1", "\$.bar1 lazy init";
    $inst.bar2 = "a string";
    is $inst.bar2, "filtered-bar2(a string)", "\$.bar2 filter";
    is $inst.baz1, "Baz1::baz1", "\$.baz1 lazy init";

    $inst = Baz1.new( foo1 => "foo1 from new", bar2 => "bar2 from new", baz1 => "baz1 from new" );
    is $inst.foo1, "foo1 from new", "foo1 from constructor";
    is $inst.bar2, "filtered-bar2(bar2 from new)", "bar2 from constructor";
    is $inst.baz1, "baz1 from new", "baz1 from constructor";
}

subtest "Chained with role", {
    plan 2;
    my $inst;

    my role FooRole {
        has $.foo is rw is mooish(:lazy);

        method build-foo { "this is foo from builder" };
    }

    my class Foo1 does FooRole {
        has $.foo1 is rw is mooish(:lazy);
        method build-foo1 { "this is foo1 from builder" };
    }

    my class Bar1 is Foo1 {
        has $.bar1 is rw is mooish(:lazy);
        method build-bar1 { "this is bar1 from builder" };
    }

    $inst =  Bar1.new;
    is $inst.foo, "this is foo from builder", "attribute from role is built";

    $inst = Bar1.new( foo => "foo from new" );
    is $inst.foo, "foo from new", "attribute from role inited by new";
}

subtest "Chained init and BUILD", {
    plan 7;
    my $inst;

    my class Foo1 {
        has $.foo1 is mooish(:predicate);
        has $.foo2;
    }

    my class Bar1 is Foo1 {
        has $.bar1 is mooish(:predicate);
        has $.bar2;

        submethod BUILD {
            pass "BUILD is active";
        }
    }

    my class Baz1 is Bar1 {
        has $.baz1 is mooish(:predicate);
        has $.baz2;
    }

    $inst = Baz1.new(
        foo1 => "foo1 from new",
        foo2 => "foo2 from new",
        bar1 => "bar1 from new",
        bar2 => "bar2 from new",
        baz1 => "baz1 from new",
        baz2 => "baz2 from new",
    );

    is $inst.foo1, "foo1 from new", "foo1 attribute ok";
    is $inst.foo2, "foo2 from new", "foo2 attribute ok";
    is $inst.bar1, Any, "bar1 attribute ok";
    is $inst.bar2, Any, "bar2 attribute ok";
    is $inst.baz1, "baz1 from new", "baz1 attribute ok";
    is $inst.baz2, "baz2 from new", "baz2 attribute ok";
}

done-testing;
# vim: ft=perl6
