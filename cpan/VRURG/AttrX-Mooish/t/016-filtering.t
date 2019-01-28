use Test;
use AttrX::Mooish;

plan 14;
my $inst;

my class Foo1 {
    has $.bar is rw is mooish(:filter);

    method filter-bar ( $value, :$attribute, *%opt ) {
        pass q<filter for attribute $.bar>;
        is $attribute, '$!bar', "filter attribute name";
        if $value == 1 {
            nok %opt<old-value>:exists, "no old value on first call";
        } else {
            ok %opt<old-value>:exists, "have old value on first call";
            is %opt<old-value>, 1.5, "correct old value";
        }
        $value + 0.5;
    }
}

$inst = Foo1.new;
$inst.bar = 1;
is $inst.bar, 1.5, "filtered value";
$inst.bar = 2;

my class Foo2 {
    has $.bar is rw is mooish(:lazy(-> $,*% {pi}), :filter);

    method filter-bar ($value, *%opt) {
        nok %opt<old-value>:exists, "no old value after builder";
        $value / 2;
    }
}

$inst = Foo2.new;
is $inst.bar, pi/2, "builder value filtered";

my class Foo3 {
    has $.bar is rw is mooish(:lazy, :filter);

    method build-bar { "from builder" }
    method filter-bar ( $value, *%opt ) {
        if $value ~~ "from builder" {
            ok %opt<builder>, "builder option is set";
        }
        else {
            nok %opt<builder>:exists, "no builder option";
        }
    }
}

$inst = Foo3.new;
$inst.bar;
$inst.bar = "not from builder";

my class Foo4 {
    has $.bar is rw is mooish(:filter, :predicate);
    has $.from-new is rw;

    submethod TWEAK {
        ok self.has-bar, "predicate is ok";
    }

    method filter-bar ( $val ) {
        $.from-new = $val ~~ "from constructor";
    }
}

$inst = Foo4.new(bar => "from constructor");
ok $inst.from-new, "filtered from constuctor";

done-testing;
# vim: ft=perl6
