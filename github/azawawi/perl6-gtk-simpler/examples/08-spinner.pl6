#!/usr/bin/env perl6

use v6;
use lib 'lib';
use GTK::Simpler;

my $app = app(title => 'Spinner');


my $spinner = spinner;

my $start-button = button(label => "Start Spinning");
my $stop-button  = button(label => "Stop Spinning");

my $hbox = hbox($start-button, $stop-button);

$start-button.clicked.tap: { $spinner.start };
$stop-button.clicked.tap:  { $spinner.stop };

my $vbox = vbox($spinner, $hbox);


$vbox.spacing = 10;

$app.set-content($vbox);

$app.border-width = 20;

$app.run;
