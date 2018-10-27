#!/usr/bin/env perl6
use v6;
use lib 'lib', '../lib';

use Math::Model;

my $m = Math::Model.new(
    derivatives => {
        velocity      => 'height',
        acceleration  => 'velocity',
    },
    variables   => {
        acceleration  => { $:gravity + $:spring + $:damping },
        gravity       => { -9.81 },
        spring        => { - 2 * $:height },
        damping       => { - 0.2 * $:velocity },
    },
    initials    => {
        height        => 0,
        velocity      => 0,
    },
    captures    => ('height', 'time'),
    numeric-error => 0.001,
);

$m.integrate(:from(0), :to(20), :min-resolution(5));
$m.render-svg("spring-damping.svg", :title("Spring with damping"));
