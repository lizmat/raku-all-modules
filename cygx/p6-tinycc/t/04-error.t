#!/usr/bin/env perl6

use v6;
use Test;

plan 3;

{
    use TinyCC *;
    tcc.catch(-> | { pass 'compilation error succesfully caught' });
    try tcc.compile('42').run;
}

{
    use TinyCC *;
    tcc.catch(-> | { die 'unexpected compilation error' });
    ok tcc.compile(q:to/__END__/).run == 2, 'can use math.h function';
        #include <math.h>
        int main(void) { return log10(100); }
        __END__
}

{
    use TinyCC { .set: |:nostdinc };
    tcc.catch(-> | { pass 'cannot use math.h function with -nostdinc' });
    try tcc.compile(q:to/__END__/).run;
        #include <math.h>
        int main(void) { return log10(100); }
        __END__
}

done-testing;
