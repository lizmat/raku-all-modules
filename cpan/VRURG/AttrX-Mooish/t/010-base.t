use Test;
use AttrX::Mooish;

plan 4;

my $author-testing = ? %*ENV<AUTHOR_TESTING>;

my %inst-records;

subtest "Class Basics" => {
    plan 23;
    my $inst;

    my class Foo1 {
        has $.initial is default(pi);
        has $.bar is rw is mooish(:lazy, :clearer, :predicate);
        has Int $.build-count = 0;
        submethod BUILD { %inst-records{self.WHICH} = True; }
        submethod DESTROY { %inst-records{self.WHICH}:delete; }
        method build-bar { $!build-count++; $!initial }
        method direct-access { $!bar }
    }

    $inst = Foo1.new;
    is $inst.bar, pi, "initialized by builder via accessor";

    my $inst2 = Foo1.new;
    is $inst2.direct-access, pi, "initialized by builder via direct access";

    $inst.bar = "foo-bar-baz";
    is $inst.bar, "foo-bar-baz", "set manually ok";
    is $inst2.bar, pi, "second object attribute unchanged";
    $inst.bar = Nil;
    nok $inst.bar.defined, "Nil value assigned";

    # So far, two object, one lazy attribute was initialized per each object.
    if $author-testing {
        is mooish-obj-count, 2, "2 used slots correspond to attribute count";
    }
    else {
        skip "author testing only", 1;
    }

        $inst = Foo1.new;
        for 1..20 {
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

    subtest "Clearer/prefix", {
        plan 4;
        $inst.bar = "something different";
        is $inst.bar, "something different", "set before clear";
        $inst.clear-bar;
        is $inst.has-bar, False, "prefix reports no value";
        is $inst.bar, pi, "cleared and re-initialized";
        is $inst.has-bar, True, "prefix reports a value";
    }

    subtest "Manual initial set", {
        plan 4;
        $inst = Foo1.new;
        $inst.bar = "bypass build";
        ok $inst.has-bar, "value has been set to check builder bypassing";
        is $inst.build-count, 0, "attribute is set manually without involving builder";
        is $inst.bar, "bypass build", "attribute value is what we set it to";
        is $inst.build-count, 0, "reading from attribute still didn't use the builder";
    }

    my class Foo2C {
        has $.barbar is rw is mooish(:lazy, :clearer, :predicate );
        has $.baz is rw;

        method build-barbar { "not from new" }
    }

    $inst = Foo2C.new( barbar => "from new",  baz => "from NEW" );
    is $inst.baz, "from NEW", "set from constructor";
    is $inst.barbar, "from new", "set from constructor";
    ok $inst.has-barbar, "predicate on attribute from constructor";
    $inst.clear-barbar;
    is $inst.barbar, "not from new", "reset and set not from constructor parameters";

    my class Foo3 {
        has $.bar is mooish(:lazy, builder => 'init-bar');
        method init-bar { "from init-bar" }
    }

    $inst = Foo3.new;
    is $inst.bar, "from init-bar", "named builder works";

    my class Foo4 {
        has $.bar is rw is mooish(:lazy, clearer => "reset-bar", predicate => "is-set-bar");

        method build-bar { "from builder" };
    }

    $inst = Foo4.new;
    $inst.bar;
    ok $inst.is-set-bar, "custom predicate name";
    lives-ok { $inst.reset-bar }, "custom clearer name";
    nok $inst.is-set-bar, "clearer did the job";

    my class Foo5 {
        has $.bar-b is mooish(:lazy, :builder(-> $s,*% {"block builder"}));
        has $.baz is mooish(:lazy, :builder(method {"method builder"}));
    }

    $inst = Foo5.new;
    is $inst.bar-b, "block builder", "block builder";
    is $inst.baz, "method builder", "method builder";

    my class Foo6 {
        has $.bar is mooish(:lazy('init-bar'));
        has $.baz is mooish(:lazy(method {"lazy builder"}));

        method init-bar {
            "init-bar builder";
        }
    }

    $inst = Foo6.new;
    is $inst.bar, "init-bar builder", "builder name defined in :lazy";
    is $inst.baz, "lazy builder", ":lazy defined callable builder";
}

subtest "Attr value resetting" => {
    plan 19;
    # Testing for a bug where attribute values were preserved in new class instances via accidental preserving of
    # .auto_viv_container
    my $inst;

    my class Foo1 {
        has @.foo is rw is mooish(:predicate);
        has Num %.bar is rw is mooish(:predicate);
        has Str $.baz is rw is mooish(:predicate);
        has &.fubar is rw is mooish(:predicate);
        has @.arr;
        has Num %.h;
        has Str $.scalar;
        has &.code;
    }

    $inst = Foo1.new;
    isa-ok $inst.foo, $inst.arr.WHAT, "initial array attribute type";
    isa-ok $inst.bar, $inst.h.WHAT, "initial (parametrized) hash attribute type";
    isa-ok $inst.baz, $inst.scalar.WHAT, "initial (parametrized) scalar attribute type";
    ok ($inst.fubar.WHAT === $inst.code.WHAT), "initial callable attribute type";
    $inst.foo = <Слава Україні!>;
    $inst.bar = a=>pi, b=>e;
    $inst.baz = "згинь, потворо!";
    my $sub = sub { "та до дідька" };
    $inst.fubar = $sub;
    is-deeply $inst.foo, [<Слава Україні!>], "array assigned";
    is-deeply $inst.bar.Map, %( a=>pi, b=>e ).Map, "hash assigned";
    is $inst.baz, "згинь, потворо!", "scalar assigned";
    ok $inst.fubar === $sub, "callable assigned";
    isa-ok $inst.foo, $inst.arr, "array attribute type preserved";
    isa-ok $inst.bar, $inst.h, "(parametrized) hash attribute type preserved";
    isa-ok $inst.baz, $inst.scalar, "(parametrized) scalar attribute type preserved";
    $inst = Foo1.new;
    isa-ok $inst.foo, $inst.arr.WHAT, "re-create: array attribute type preserved";
    isa-ok $inst.bar, $inst.h.WHAT, "re-create: (parametrized) hash attribute type preserved";
    isa-ok $inst.baz, $inst.scalar.WHAT, "re-create: (parametrized) scalar attribute type preserved";
    ok ($inst.fubar.WHAT === $inst.code.WHAT), "re-create: callable attribute type preserved";
    is-deeply $inst.foo, [], "array attribute is empty";
    is-deeply $inst.bar.Map, %( ).Map, "hash attribute is empty";
    nok $inst.baz.defined, "scalar is undefined";
    nok $inst.fubar.defined, "callable is undefined";
}

subtest "Lazy Chain", {
    plan 2;
    my $inst;

    my class Foo1 {
        has $.bar is rw is mooish(:lazy);
        has $.baz is rw is mooish(:lazy);

        method build-bar { "foo bar" }
        method build-baz { "({$!bar}) and baz" }
    }

    $inst = Foo1.new;
    is $inst.baz, "(foo bar) and baz", "lazy initialized from lazy";

    my class Foo2 {
        has $.bar is rw is mooish(:lazy);

        method take-a-value { pi }
        method build-bar { self.take-a-value * e }
    }

    $inst = Foo2.new;
    is $inst.bar, pi * e, "lazy initialized from a method";
}

subtest "Constructor init", {
    plan 2;
    my $inst;
    my class Foo1 {
        has @.bar is mooish(:predicate);
        has @.foo ;
    }

    $inst = Foo1.new( :bar(1,2,3), :foo(<a b c>) );
    is-deeply $inst.bar, [1,2,3], 'mooish array attribute init from new';
    is-deeply $inst.foo, [<a b c>], 'non-mooish array attribute init from new';
}

done-testing;
# vim: ft=perl6
