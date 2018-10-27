#!/usr/bin/env perl6

use v6;

use lib 'lib';
use GTK::Simpler;

my $app        = app(:title("Frame Demo"));
my $text-view  = text-view(:text("Some Text"));
my $frame      = frame(:label("Some Label"));
my $vbox       = vbox($text-view);
$vbox.border-width = 20;
$frame.set-content( $vbox );
$app.set-content( $frame );
$app.border-width = 20;

$app.run;
