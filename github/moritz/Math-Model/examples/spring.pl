use v6;
use lib 'lib', '../lib';

use Math::Model;

for 0.05, *+0.02  ... 0.4 -> $freq {
    my $m = Math::Model.new(
        derivatives => {
            velocity      => 'height',
            acceleration  => 'velocity',
        },
        variables   => {
            acceleration  => { $:gravity + $:spring + $:damping + $:ext_force },
            gravity       => { -9.81 },
            spring        => { - 2 * $:height },
            damping       => { - 0.5 * $:velocity },
            ext_force     => { sin(2 * pi * $:time * $freq) },
        },
        initials    => {
            height        => 0,
            velocity      => 0,
        },
        captures    => ('height', 'time'),
        numeric-error => 0.001,
    );

    my %h = $m.integrate(:from(0), :to(50), :min-resolution(5));
    $m.render-svg("spring-freq-$freq.svg", :title("Spring with damping, external force at $freq"));
    $m = Any;

    my @ampl = (%h<time>.flat Z=> %h<height>.flat).grep({.key >= 30})».value;
    my $min = @ampl.min;
    my $max = @ampl.max;

    say "res: $freq\t{$max - $min}";
}
