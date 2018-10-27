use v6;
use lib '../lib';

use Math::Model;

for 30, 45, 60 -> $angle {

    my $m = Math::Model.new(
        derivatives => {
            y_velocity      => 'y',
            y_acceleration  => 'y_velocity',
            x_velocity      => 'x',
        },
        variables   => {
            y_acceleration  => { $:force / $:mass },
            mass            => { 1 },           # kg
            force           => { -9.81 },       # N = kg m / s**2
            x_velocity      => { 20 * cos($angle, Degrees) } # m / s
        },
        initials    => {
            y               => 0,               # m
            y_velocity      => 20 * sin($angle, Degrees),    # m/s
            x               => 0,               # m
        },
        captures    => <y x>,
    );

    $m.integrate(:from(0), :to(2 * 20 * sin($angle, Degrees) / 9.81), :min-resolution(0.2));
    $m.render-svg("throw-angle-$angle.svg", :x-axis<x>,
                  :width(300), :height(200),
                  :title("Throwing at $angle degreees"));
}
