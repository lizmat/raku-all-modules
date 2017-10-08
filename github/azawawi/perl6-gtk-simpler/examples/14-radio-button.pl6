#!/usr/bin/env perl6

use v6;
use lib 'lib';
use GTK::Simpler;

my $app = app(title => 'Radio Button Demo');

my $radio1-button = radio-button(:label("Bread"));
my $radio2-button = radio-button(:label("Cheese"));
my $radio3-button = radio-button(:label("Milk"));
my $radio4-button = radio-button(:label("Meat"));
my $text-view     = text-view;

$radio2-button.add($radio1-button);
$radio3-button.add($radio1-button);
$radio4-button.add($radio1-button);

sub show-radio-button-status($) {
    my @radio-buttons = ($radio1-button, $radio2-button, $radio3-button,
        $radio4-button);
    my $text = '';
    for @radio-buttons -> $radio-button {
        my $status = $radio-button.status ?? "Selected" !! "Unselected";
        $text ~= sprintf("%s is %s\n", $radio-button.label, $status);
    }
    $text-view.text = $text;
}

$radio1-button.toggled.tap: &show-radio-button-status;
$radio2-button.toggled.tap: &show-radio-button-status;
$radio3-button.toggled.tap: &show-radio-button-status;
$radio4-button.toggled.tap: &show-radio-button-status;

show-radio-button-status(Nil);

$app.set-content(
    hbox(
        vbox($radio1-button, $radio2-button, $radio3-button, $radio4-button),
        $text-view,
    )
);

$app.border-width = 20;
$app.run;
