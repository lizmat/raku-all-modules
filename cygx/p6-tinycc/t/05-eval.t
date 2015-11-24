#!/usr/bin/env perl6

use v6;
use Test;

use TinyCC::Eval;
use TinyCC::Types;

plan 3;

{
    my $rv = EVAL 'int main() { return 42; }', :lang<C>;
    ok $rv == 42, 'EVAL yields correct return value';
}

{
    my $out = cval(uint64);

    EVAL q:to/__END__/, :lang<C>, init => { .define: N => 33; .declare: :$out };
        extern unsigned long long out;

        static unsigned long long fib(unsigned n) {
            return n < 2 ? n : fib(n - 1) + fib(n - 2);
        }

        int main(void) {
            out = fib(N);
            return 0;
        }
        __END__

    ok $out.deref == (0, 1, *+* ... *)[33], 'EVAL can access symbols and defines';
}

{
    my class Point is repr<CStruct> {
        has num64 $.x;
        has num64 $.y;
    }

    my $point = Point.new(x => 0e0, y => 0e0);

    EVAL q:to/__END__/, :lang<C>, init => { .declare: :$point };
        extern struct { double x, y; } point;
        int main() {
            point.x = 0.5;
            point.y = 1.5;
        }
        __END__

    ok $point.x == 0.5 && $point.y == 1.5, 'can access CStruct from EVAL';
}

done-testing;
