#!/usr/bin/env perl6

use v6;
use lib 'lib';
use GTK::Simpler;

my $app = app(title => 'Level Bar Demo');

my $level-bar       = level-bar;
my $inc-button      = button(:label("+"));
my $dec-button      = button(:label("-"));
my $inverted-button = toggle-button(:label("Inverted"));
my $text-view       = text-view;

sub update-status {
    $text-view.text = sprintf("value=%3.2f, min=%3.2f, max=%3.2f, inverted=%s\n",
        $level-bar.value, $level-bar.min-value, $level-bar.max-value,
        $level-bar.inverted);
}

$inc-button.clicked.tap: {
    $level-bar.value = Num(min($level-bar.value + 0.1, $level-bar.max-value));
    update-status;
}

$dec-button.clicked.tap: {
    $level-bar.value = Num(max($level-bar.value - 0.1, $level-bar.min-value));
    update-status;
}

$inverted-button.clicked.tap: {
    $level-bar.inverted = $inverted-button.status;
    update-status;
}


$level-bar.offset-changed.tap: {
    $text-view.text ~= "offset-changed triggered\n";
    update-status;
}

update-status;

$app.set-content(
    vbox([
        hbox($inc-button, $dec-button, $inverted-button),
        $level-bar,
        $text-view,
    ])
);

$app.border-width = 20;
$app.run;
