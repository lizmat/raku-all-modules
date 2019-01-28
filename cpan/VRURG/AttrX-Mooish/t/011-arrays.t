use Test;
use AttrX::Mooish;

plan 7;
my $inst;

my class Foo1 {
    has @.bar is rw is mooish(:lazy, :trigger);

    method build-bar { pass "build-bar "; [ 1,2,3,pi,4 ] }
    method trigger-bar ( @value ) { 
        pass "trigger on array attribute";
    }
}

$inst = Foo1.new;
is $inst.bar.elems, 5, "correct number of elements";
is $inst.bar[3], pi, "a value from lazy array attribute";
$inst.bar[1] = e;
is $inst.bar[1], e, "changed value from lazy array attribute";
$inst.bar = [ <a b c d e> ];
is-deeply $inst.bar, [ <a b c d e> ], "new array assigned";

done-testing;
# vim: ft=perl6
