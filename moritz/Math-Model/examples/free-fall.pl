use v6;
BEGIN { @*INC.push: '../lib' };

use Math::Model;

my $m = Math::Model.new(
    derivatives => {
        velocity      => 'height',
        acceleration  => 'velocity',
    },
    variables   => {
        acceleration  => { $:gravity },   # m / s**2
        gravity       => { -9.81 },       # m / s**2
    },
    initials    => {
        height        => 50,              # m
        velocity      => 0,               # m/s
    },
    captures    => ('height', 'velocity'),
);

$m.integrate(:from(0), :to(4.2), :min-resolution(0.2));
$m.render-svg('free-fall.svg', :title('Free falling'));
