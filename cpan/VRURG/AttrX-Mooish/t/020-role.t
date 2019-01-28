use Test;
use AttrX::Mooish;

plan 3;

my $author-testing = ? %*ENV<AUTHOR_TESTING>;

my %inst-records;

subtest "Role Basics", {
    plan 17;

    my $inst;

    my role FooRole1 {
        has $.bar is rw is mooish(:lazy, :clearer, :predicate);
        has Int $.build-count = 0;

        method build-bar { $!build-count++; "is bar" }
        method direct-access { $!bar }
    }

    my class FooR1 does FooRole1 {
        has $.baz is rw;

        submethod BUILD { %inst-records{self.WHICH} = True }
        submethod DESTROY { %inst-records{self.WHICH}:delete };
    }

    $inst = FooR1.new;
    is $inst.bar, "is bar", "initialized from builder";

    my $inst2 = FooR1.new;
    is $inst2.direct-access, "is bar", "initialized by builder via direct access";

    $inst.bar = "manual value";
    is $inst.bar, "manual value", "set manually";
    # Test if we occasionally use same back store for attributes
    is $inst2.bar, "is bar", "second object attribute unchanged";

    if $author-testing {
        # So far, two object, one lazy attribute was initialized per each object.
        is mooish-obj-count, 2, "2 used slots correspond to attribute count";
    }
    else {
        skip "author testing only", 1;
    }
    # Self-check the test
    is %inst-records.keys.elems, 2, "two control instance records found";

    $inst = FooR1.new;
    for 1..2000 {
        my $v = $inst.bar;
    }

    is $inst.build-count, 1, "initialized only once";
    if $author-testing {
        is mooish-obj-count, 3, "3 used slots correspond to attribute count";

        for 1..20000 {
            $inst = FooR1.new;
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
    is $inst.bar, "is bar", "cleared and re-initialized";
    is $inst.has-bar, True, "prefix reports a value";

    my role FooRole2 {
        has $.bar is rw is mooish(:lazy, :clearer);
        has $.baz is rw;

        method build-bar { "not from new" }
    }

    my class FooR2 does FooRole2 {
    }

    $inst = FooR2.new( bar => "from new",  baz => "from NEW" );
    is $inst.baz, "from NEW", "set from constructor";
    is $inst.bar, "from new", "set from constructor";
    $inst.clear-bar;
    is $inst.bar, "not from new", "reset and set not from constructor parameters";

    my role FooRole3 {
        has $.bar is mooish(:lazy, builder => 'init-bar');
        method init-bar { "from init-bar" }
    }

    my class FooR3 does FooRole3 {
    }

    $inst = FooR3.new;
    is $inst.bar, "from init-bar", "named builder works";
}

subtest "Require method", {
    plan 2;
    my $inst;

    my role FooRole1 {
        has $.bar is rw is mooish(:filter);
        method filter-bar {...}
    }

    throws-like
        q<my class FooR1 does FooRole1 { }>,
        X::AdHoc,
        message => q<Method 'filter-bar' must be implemented by FooR1 because it is required by roles: FooRole1.>,
        "cannot compose without required method";

    my class FooR2 does FooRole1 {
        method filter-bar ($val) { "filtered-FooR2($val)" }
    }

    $inst = FooR2.new;
    $inst.bar = "fubar";
    is $inst.bar, "filtered-FooR2(fubar)", "role's requirement";
}

subtest "Private Methods", {
    plan 6;
    my $inst;

    my role FooRole {
        has %!foo is mooish(:lazy, :clearer);
        has $.build-count = 0;

        method !build-foo { $!build-count++; :a("private foo") }

        method cleanup {
            self!clear-foo;
        }

        method get-foo { %!foo }
    }

    my role BarRole does FooRole {
        has $.bar is mooish(:lazy, :clearer);
        method for-punning { "ok" }
        method build-bar { "public bar" }
    }

    my role BazRole {
        has $.baz is mooish(:lazy, :clearer);
        method build-baz { "public baz" }
    }

    my class FooR1 does BarRole does BazRole {
        method re-clean { self!clear-foo }
    }

    $inst = FooR1.new;

    BarRole.for-punning;

    is $inst.get-foo<a>, "private foo", "default build";
    is $inst.build-count, 1, "build count is 2";
    $inst.cleanup;
    is $inst.get-foo<a>, "private foo", "build after role-initiated clear";
    is $inst.build-count, 2, "build count is 2";
    $inst.re-clean;
    is $inst.get-foo<a>, "private foo", "build after class-initiated clear";
    is $inst.build-count, 3, "build count is 3";
}

done-testing;

# vim: ft=perl6
