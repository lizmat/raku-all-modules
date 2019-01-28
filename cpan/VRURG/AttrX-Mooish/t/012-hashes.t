use Test;
use AttrX::Mooish;

plan 7;
my $inst;

my class Foo1 {
    has %.bar is rw is mooish(:lazy, :trigger);

    method build-bar { pass "build-bar "; { a => 1, b => 2, c => 3, p => pi } }
    method trigger-bar ( %value ) { 
        pass "trigger on array attribute";
    }
}

$inst = Foo1.new;
is $inst.bar.elems, 4, "correct number of elements";
is $inst.bar<p>, pi, "a value from lazy array attribute";
$inst.bar<e> = e;
is $inst.bar<e>, e, "changed value from lazy array attribute";
$inst.bar = { x => 0.1, y => 0.2, z => 0.3 };
is-deeply $inst.bar, { x => 0.1, y => 0.2, z => 0.3 }, "new hash assigned";

done-testing;
# vim: ft=perl6
