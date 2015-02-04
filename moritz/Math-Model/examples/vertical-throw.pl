use v6;
BEGIN { @*INC.push: '../lib' };

use Math::Model;

my $m = Math::Model.new(
    derivatives => {
        y_velocity      => 'y',
        y_acceleration  => 'y_velocity',
    },
    variables   => {
        y_acceleration  => { $:force / $:mass },
        mass            => { 1 },           # kg
        force           => { -9.81 },       # N = kg m / s**2
    },
    initials    => {
        y               => 0,               # m
        y_velocity      => 20,              # m/s
    },
    captures    => ('y', 'y_velocity'),
);

$m.integrate(:from(0), :to(4.2), :min-resolution(0.2));
$m.render-svg('throw-vertically.svg', :title('vertical throwing'));
