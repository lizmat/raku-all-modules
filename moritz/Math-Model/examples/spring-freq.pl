#!/usr/bin/env perl6
use v6;
BEGIN { @*INC.push: '../lib' };

use Math::Model;

sub MAIN($freq) {
    my $m = Math::Model.new(
        derivatives => {
            velocity      => 'height',
            acceleration  => 'velocity',
        },
        variables   => {
            acceleration  => { $:gravity + $:spring + $:damping + $:ext_force },
            gravity       => { -9.81 },
            spring        => { - 2 * $:height },
            damping       => { - 0.2 * $:velocity },
            ext_force     => { sin(2 * pi * $:time * $freq) },
        },
        initials    => {
            height        => 0,
            velocity      => 0,
        },
        captures    => ('height', 'time'),
        numeric-error => 0.001,
    );

    my %h = $m.integrate(:from(0), :to(70), :min-resolution(5));
    $m.render-svg("spring-freq-$freq.svg", :title("Spring with damping, external force at $freq"));
    $m = Any;

    my @ampl = (%h<time>.flat Z=> %h<height>.flat).grep({.key >= 50})».value;
    my $min = @ampl.min;
    my $max = @ampl.max;

    say "res: $freq\t{$max - $min}";
}
