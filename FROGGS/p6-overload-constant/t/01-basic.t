use v6;
use lib 'lib';
use Test;

plan 9;

{
    sub integer { "i$^a" }
    sub decimal { "d$^a" }
    sub radix   { "r$^a" }
    sub numish  { "n$^a" }
    use overload::constant &integer, &decimal, &radix, &numish;

    ok 42      ~~ Str && 42      eq 'i42',      'can overload integer';
    ok 0.12    ~~ Str && 0.12    eq 'd0.12',    'can overload decimal';
    ok .1e-003 ~~ Str && .1e-003 eq 'd.1e-003', 'can overload decimal in scientific notation';
    ok :16<FF> ~~ Str && :16<FF> eq 'r:16<FF>', 'can overload radix';
    ok NaN     ~~ Str && NaN     eq 'nNaN',     'can overload other numish things';
}

{
    sub integer { $^a; 1.0 }
    use overload::constant &integer;

    ok 42 == 1.0, 'overloaded integer can return a Rat';
}

{
    sub integer { $^a; 21 }
    use overload::constant &integer;

    ok 42 == 21.0, 'overloaded integer can return an integer';
}

ok 42 !~~ Str,  'overload only happens inside its scope';
ok 42  == 42.0, 'overload only happens inside its scope';
