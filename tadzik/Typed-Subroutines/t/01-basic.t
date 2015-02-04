use Test;
plan 17;

use Typed::Subroutines;

subset TwoArgSub of Sub where typed_sub(Any, Any);

my TwoArgSub $a;

lives_ok { $a = sub ($a, $b)     { } }, 'lives 1';
dies_ok  { $a = sub ()           { } };
dies_ok  { $a = sub ($a)         { } };
dies_ok  { $a = sub ($a, $b, $c) { } };

subset TakesIntAndString of Sub where typed_sub(Int, Str);

my TakesIntAndString $b;

lives_ok { $b = sub (Int $a, Str $b)     { } }, 'lives 2';
dies_ok  { $b = sub (Int $a, $b)         { } };
dies_ok  { $b = sub ($a, Str $b)         { } };
dies_ok  { $b = sub (Str $a, Int $b)     { } };
dies_ok  { $b = sub (Int $a, Str $b, $c) { } };

sub operateOnSomething(
    Int $a,
    Str $b,
    &operation where typed_sub(Int, Str)
) {
    return &operation($a, $b)
}

sub test_op(Int $a, Str $b) {
    return $a ~ $b
}

is test_op(5, " hundred miles"), '5 hundred miles',
                                 'test_op does what I meant';

lives_ok { operateOnSomething(5, ' hundred miles', &test_op) },'lives 3';
is operateOnSomething(5, ' hundred miles', &test_op), '5 hundred miles';

lives_ok {
    operateOnSomething(5, ' hundred miles', sub (Int $a, Str $b) {
        return $a ~ $b
    })
}, 'anonymous sub works';

my $pointy =  -> Int $a, Str $b { return $a ~ $b };

lives_ok { operateOnSomething(5, ' hundred miles', $pointy) },
         'pointy block works';

lives_ok {
    operateOnSomething(5, ' hundred miles', -> Int $a, Str $b {
        return $a ~ $b
    })
}, 'anonymous pointy block works';

$pointy = -> $x { "lalala" };

dies_ok { operateOnSomething(5, ' hundred miles', $pointy) },
        'incorrect pointy dies';

dies_ok {
    operateOnSomething(99, "bottles of beer", -> Rat $a, Num $b { "a" })
}, 'example from SYNOPSIS';
