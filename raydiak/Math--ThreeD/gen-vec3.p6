#!/usr/bin/env perl6

use v6;

use lib $?FILE.IO.dirname;
use Generator;

Math::ThreeD::Library.new(
    name => 'Vec3',
    dims => [3],
    use => 'Math::ThreeD::Mat44',
    ops => (

        op( operator => '+',
            function => 'add',
            mutator => 'plus',
            args => [[ <obj> ],[ <num> ]],

        ),

        op( operator => '-',
            function => 'sub',
            mutator => 'minus',
            args => [[ <obj> ],[ <num> ]],
        ),

        op( operator => '-',
            function => 'neg',
            mutator => 'negate',
        ),

        op( operator => '*',
            function => 'mul',
            mutator => 'times',
            args => [[ <obj> ],[ <num> ]],
        ),

        op( operator => '/',
            function => 'div',
            mutator => 'divide',
            args => [[ <obj> ],[ <num> ]],
        ),

        op( operator => '%',
            function => 'mod',
            mutator => 'modulus',
            args => [[ <obj> ],[ <num> ]],
        ),

        op( operator => '!',
            postfix => True,
            # not correct or optimal; just testing postfix
            expressions => ['([*] 1..$a[0])', '([*] 1..$a[1])', '([*] 1..$a[2])'],
        ),

        op( operator => '⨯',
            # https://rt.perl.org/Public/Bug/Display.html?id=126508
            # function => 'cross',
            mutator => 'cross-with',
            args => [ ['obj'], ],
            expressions => [
                '$a[1] * $b[2] - $a[2] * $b[1]',
                '$a[2] * $b[0] - $a[0] * $b[2]',
                '$a[0] * $b[1] - $a[1] * $b[0]'
            ],
        ),

        op( operator => '⋅',
            function => 'dot',
            args => [ ['obj'], ],
            return => 'num',
            expression => '$a[0]*$b[0] + $a[1]*$b[1] + $a[2]*$b[2]',
        ),

        op( function => 'length_sqr',
            return => 'num',
            expression => '$a[0]*$a[0] + $a[1]*$a[1] + $a[2]*$a[2]',
        ),

        op( function => 'length',
            return => 'num',
            expression => 'sqrt( $a[0]*$a[0] + $a[1]*$a[1] + $a[2]*$a[2] )',
        ),

        op( function => 'rot-x',
            mutator => 'rotate-x',
            args => [ ['num'], ],
            intro => 'my ($sin, $cos) = sin($b), cos($b);',
            expressions => [
                '$a[0]',
                '$a[1] * $cos - $a[2] * $sin',
                '$a[1] * $sin + $a[2] * $cos',
            ],
        ),

        op( function => 'rot-y',
            mutator => 'rotate-y',
            args => [ ['num'], ],
            intro => 'my ($sin, $cos) = sin($b), cos($b);',
            expressions => [
                '$a[0] * $cos - $a[2] * $sin',
                '$a[1]',
                '$a[0] * $sin + $a[2] * $cos',
            ],
        ),

        op( function => 'rot-z',
            mutator => 'rotate-z',
            args => [ ['num'], ],
            intro => 'my ($sin, $cos) = sin($b), cos($b);',
            expressions => [
                '$a[0] * $cos - $a[1] * $sin',
                '$a[0] * $sin + $a[1] * $cos',
                '$a[2]',
            ],
        ),

        op( function => 'rot',
            mutator => 'rotate',
            args => [ <obj num>, ],
            intro => 
q[my $sin = sin $c;
my $cos = cos $c;
my $dot_scaled = $b.dot($a) * (1 - $cos);
my $cross = $b.cross($a);],
            expressions => [
                '$a[0] * $cos + $cross[0] * $sin + $b[0] * $dot_scaled',
                '$a[1] * $cos + $cross[1] * $sin + $b[1] * $dot_scaled',
                '$a[2] * $cos + $cross[2] * $sin + $b[2] * $dot_scaled',
            ],
        ),

        op( function => 'trans',
            mutator => 'transform',
            args => [ ['Mat44'], ],
            expressions => [
                '$a[0]*$b[0][0] + $a[1]*$b[0][1] + $a[2]*$b[0][2] + $b[0][3]',
                '$a[0]*$b[1][0] + $a[1]*$b[1][1] + $a[2]*$b[1][2] + $b[1][3]',
                '$a[0]*$b[2][0] + $a[1]*$b[2][1] + $a[2]*$b[2][2] + $b[2][3]',
            ],
        ),

        op( function => 'norm',
            mutator => 'normalize',
            intro => 'my $l = $a.length || 1;',
            expressions => [
                '$a[0] / $l',
                '$a[1] / $l',
                '$a[2] / $l',
            ],
        ),

        op( function => 'refl',
            mutator => 'reflect',
            args => [[ <obj> ],],
            intro => 'my $scale = 2 * $a.dot($b);',
            expressions => [
                '$b[0] * $scale - $a[0]',
                '$b[1] * $scale - $a[1]',
                '$b[2] * $scale - $a[2]',
            ],
        ),

    ),
).write('lib/Math/ThreeD/Vec3.pm');

# vim: set expandtab:ts=4:sw=4
