#!/usr/bin/env perl6

use v6;

use GTK::Simple::App;
use GTK::Simple::Frame;
use GTK::Simple::TextView;
use GTK::Simple::VBox;

my $app = GTK::Simple::App.new( :title("Frame Demo"), :height(60));

my $text-view  = GTK::Simple::TextView.new( :text("Some Text"));

my $vbox = GTK::Simple::VBox.new($text-view);
$vbox.border-width = 2;

my $frame = GTK::Simple::Frame.new(:label("Some Label"));
$frame.set-content( $vbox );

$app.set-content( $frame );
$app.border-width = 2;
$app.run;
