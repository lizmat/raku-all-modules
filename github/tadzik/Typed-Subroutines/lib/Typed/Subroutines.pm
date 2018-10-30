unit module Typed::Subroutines;

sub typed_sub(*@types) is export {
    DEPRECATED('subset (...) of Sub where :($, Str, etc)');
    return sub ($s) {
        $s.signature.params == +@types
        and @types ~~ $s.signature.params.map(*.type).Array
    }
}

=begin pod

=head1 SYNOPSIS

    use Typed::Subroutines;

    # create a subtype from Sub
    subset TwoArgSub         of Sub where typed_sub(Any, Any);
    subset TakesIntAndString of Sub where typed_sub(Int, Str);

    my TwoArgSub         $a;
    my TakesIntAndString $b;

    $a = sub ($a, $b) { ... }; # lives
    $a = sub ($a)     { ... }; # dies

    $b = sub (Int $a, Str $b) { ... }; # lives
    $b = sub (Int $a,     $b) { ... }; # dies

    # validate subroutines passed to your subroutines (dawg)
    sub doStuff(Int $a, Str $b, &operation where typed_sub(Int, Str)}) {
        ...
    }

    doStuff(99, "bottles of beer", -> Int $a, Str $b { ... }) # lives
    doStuff(99, "bottles of beer", -> Rat $a, Num $b { ... }) # dies

=head1 DESCRIPTION

Typed::Subroutines let you specify subroutine types verifying the
parameter list so you can have better type checking for
first-class functions.

I'll write more docs when I'm less tired.

=end pod
