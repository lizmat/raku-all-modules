#!/usr/bin/env perl6

use v6;
use lib 'lib';
use GTK::Simpler;

my $app = app(title => "Toggle buttons");

$app.set-content(
    vbox(
        my $check-button  = check-button(label => "check me out!"),
        my $status-label  = label(text => "the toggles are off and off"),
        my $toggle-button = toggle-button(label=> "time to toggle!"),
    )
);


$app.border-width = 50;

sub update-label($b) {
    $status-label.text = "the toggles are " ~
        ($check-button, $toggle-button)>>.status.map({ <off on>[$_] }).join(" and ");
}


$check-button.toggled.tap:  &update-label;
$toggle-button.toggled.tap: &update-label;

$app.run;
