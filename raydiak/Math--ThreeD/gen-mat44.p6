#!/usr/bin/env perl6

use v6;

use lib $?FILE.IO.dirname;
use Generator;

Math::ThreeD::Library.new(
    name => 'Mat44',
    dims => [4, 4],
    ops => (

        op( function => 'mat44-trans',
            args => [[ <num num num> ]],
            :!selfarg,
            expressions => [ <
                1 0 0 $a
                0 1 0 $b
                0 0 1 $c
                0 0 0  1
            > ],
        ),

        op( function => 'mat44-scale',
            args => [[ <num num num> ]],
            :!selfarg,
            expressions => [ <
                $a  0  0 0
                 0 $b  0 0
                 0  0 $c 0
                 0  0  0 1
            > ],
        ),

        op( function => 'mat44-rot-x',
            args => [[ <num> ]],
            :!selfarg,
            intro => 'my ($sin, $cos) = sin($a), cos($a);',
            expressions => [ <
                 1    0     0 0
                 0 $cos -$sin 0
                 0 $sin  $cos 0
                 0    0     0 1
            > ],
        ),

        op( function => 'mat44-rot-y',
            args => [[ <num> ]],
            :!selfarg,
            intro => 'my ($sin, $cos) = sin($a), cos($a);',
            expressions => [ <
                $cos 0 -$sin 0
                   0 1     0 0
                $sin 0  $cos 0
                   0 0     0 1
            > ],
        ),

        op( function => 'mat44-rot-z',
            args => [[ <num> ]],
            :!selfarg,
            intro => 'my ($sin, $cos) = sin($a), cos($a);',
            expressions => [ <
                $cos -$sin 0 0
                $sin  $cos 0 0
                   0     0 1 0
                   0     0 0 1
            > ],
        ),

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

        op( function => 'inv',
            mutator => 'invert',
            intro =>
q[[[my $s = [
    $a[0][0] * $a[1][1] - $a[1][0] * $a[0][1],
    $a[0][0] * $a[1][2] - $a[1][0] * $a[0][2],
    $a[0][0] * $a[1][3] - $a[1][0] * $a[0][3],
    $a[0][1] * $a[1][2] - $a[1][1] * $a[0][2],
    $a[0][1] * $a[1][3] - $a[1][1] * $a[0][3],
    $a[0][2] * $a[1][3] - $a[1][2] * $a[0][3]
];

my $c = [
    $a[2][0] * $a[3][1] - $a[3][0] * $a[2][1],
    $a[2][0] * $a[3][2] - $a[3][0] * $a[2][2],
    $a[2][0] * $a[3][3] - $a[3][0] * $a[2][3],
    $a[2][1] * $a[3][2] - $a[3][1] * $a[2][2],
    $a[2][1] * $a[3][3] - $a[3][1] * $a[2][3],
    $a[2][2] * $a[3][3] - $a[3][2] * $a[2][3]
];

my $det =
    $s[0] * $c[5] -
    $s[1] * $c[4] +
    $s[2] * $c[3] +
    $s[3] * $c[2] -
    $s[4] * $c[1] +
    $s[5] * $c[0];

die "Cannot invert zero-determinant matrix:\n{$a.perl}" unless $det;

my $invdet = 1 / $det;]]],
            expressions => [
                '( $a[1][1] * $c[5] - $a[1][2] * $c[4] + $a[1][3] * $c[3]) * $invdet',
                '(-$a[0][1] * $c[5] + $a[0][2] * $c[4] - $a[0][3] * $c[3]) * $invdet',
                '( $a[3][1] * $s[5] - $a[3][2] * $s[4] + $a[3][3] * $s[3]) * $invdet',
                '(-$a[2][1] * $s[5] + $a[2][2] * $s[4] - $a[2][3] * $s[3]) * $invdet',
                '(-$a[1][0] * $c[5] + $a[1][2] * $c[2] - $a[1][3] * $c[1]) * $invdet',
                '( $a[0][0] * $c[5] - $a[0][2] * $c[2] + $a[0][3] * $c[1]) * $invdet',
                '(-$a[3][0] * $s[5] + $a[3][2] * $s[2] - $a[3][3] * $s[1]) * $invdet',
                '( $a[2][0] * $s[5] - $a[2][2] * $s[2] + $a[2][3] * $s[1]) * $invdet',
                '( $a[1][0] * $c[4] - $a[1][1] * $c[2] + $a[1][3] * $c[0]) * $invdet',
                '(-$a[0][0] * $c[4] + $a[0][1] * $c[2] - $a[0][3] * $c[0]) * $invdet',
                '( $a[3][0] * $s[4] - $a[3][1] * $s[2] + $a[3][3] * $s[0]) * $invdet',
                '(-$a[2][0] * $s[4] + $a[2][1] * $s[2] - $a[2][3] * $s[0]) * $invdet',
                '(-$a[1][0] * $c[3] + $a[1][1] * $c[1] - $a[1][2] * $c[0]) * $invdet',
                '( $a[0][0] * $c[3] - $a[0][1] * $c[1] + $a[0][2] * $c[0]) * $invdet',
                '(-$a[3][0] * $s[3] + $a[3][1] * $s[1] - $a[3][2] * $s[0]) * $invdet',
                '( $a[2][0] * $s[3] - $a[2][1] * $s[1] + $a[2][2] * $s[0]) * $invdet',
            ],
        ),

        op( function => 'prod',
            mutator => 'product',
            args => [[ <obj> ]],
            expressions => [
                '$a[0][0]*$b[0][0] + $a[0][1]*$b[1][0] + $a[0][2]*$b[2][0] + $a[0][3]*$b[3][0]',
                '$a[0][0]*$b[0][1] + $a[0][1]*$b[1][1] + $a[0][2]*$b[2][1] + $a[0][3]*$b[3][1]',
                '$a[0][0]*$b[0][2] + $a[0][1]*$b[1][2] + $a[0][2]*$b[2][2] + $a[0][3]*$b[3][2]',
                '$a[0][0]*$b[0][3] + $a[0][1]*$b[1][3] + $a[0][2]*$b[2][3] + $a[0][3]*$b[3][3]',
                
                '$a[1][0]*$b[0][0] + $a[1][1]*$b[1][0] + $a[1][2]*$b[2][0] + $a[1][3]*$b[3][0]',
                '$a[1][0]*$b[0][1] + $a[1][1]*$b[1][1] + $a[1][2]*$b[2][1] + $a[1][3]*$b[3][1]',
                '$a[1][0]*$b[0][2] + $a[1][1]*$b[1][2] + $a[1][2]*$b[2][2] + $a[1][3]*$b[3][2]',
                '$a[1][0]*$b[0][3] + $a[1][1]*$b[1][3] + $a[1][2]*$b[2][3] + $a[1][3]*$b[3][3]',
                
                '$a[2][0]*$b[0][0] + $a[2][1]*$b[1][0] + $a[2][2]*$b[2][0] + $a[2][3]*$b[3][0]',
                '$a[2][0]*$b[0][1] + $a[2][1]*$b[1][1] + $a[2][2]*$b[2][1] + $a[2][3]*$b[3][1]',
                '$a[2][0]*$b[0][2] + $a[2][1]*$b[1][2] + $a[2][2]*$b[2][2] + $a[2][3]*$b[3][2]',
                '$a[2][0]*$b[0][3] + $a[2][1]*$b[1][3] + $a[2][2]*$b[2][3] + $a[2][3]*$b[3][3]',
                
                '$a[3][0]*$b[0][0] + $a[3][1]*$b[1][0] + $a[3][2]*$b[2][0] + $a[3][3]*$b[3][0]',
                '$a[3][0]*$b[0][1] + $a[3][1]*$b[1][1] + $a[3][2]*$b[2][1] + $a[3][3]*$b[3][1]',
                '$a[3][0]*$b[0][2] + $a[3][1]*$b[1][2] + $a[3][2]*$b[2][2] + $a[3][3]*$b[3][2]',
                '$a[3][0]*$b[0][3] + $a[3][1]*$b[1][3] + $a[3][2]*$b[2][3] + $a[3][3]*$b[3][3]',
            ],
        ),

    ),
).write('lib/Math/ThreeD/Mat44.pm');

# vim: set expandtab:ts=4:sw=4
