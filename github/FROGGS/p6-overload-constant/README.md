## overload::constant

It is meant to work a bit like P5's overload::constant[1], though it is kind of pre-alpha here.

## USAGE

```perl6
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
```

[1] http://perldoc.perl.org/overload.html#Overloading-Constants
