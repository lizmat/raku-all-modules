use Test;
use lib "lib";

use Injector;

role Rand { method r {…} }

class RandStr does Rand {
    has $.r = ("a" .. "z").roll(rand * 10).join;
}

class C2 {
    has Int 	$.a is injected;
	has Rand:U 	$.r is injected;
}

class C1 {
    has C2      $.c2    is injected;
    has Int     $.b     is injected<test>;
    has Rand    $.r     is injected{:lifecycle<instance>};
}

BEGIN {
    bind 42                  ;
    bind 13,      :name<test>;
    bind RandStr, :to(Rand)  ;
}

my C1 $c is injected;
ok $c.defined;
is $c.c2.a, 42;
is $c.b, 13;
ok $c.r.defined;

my $first1;
my $first2;
for ^2 -> $i {
    given C1.new: :123b {
        is .c2.a, 42;
        is .b, 123;
        if $i == 0 {
            $first1 = .c2.r;
            $first2 = .r;
        } else {
            is $first1, .c2.r;
            isnt $first2, .r;
        }
    }
}


done-testing
