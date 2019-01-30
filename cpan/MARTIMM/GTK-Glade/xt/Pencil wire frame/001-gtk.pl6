#!/usr/bin/env perl6

use v6;
use GTK::Simple;
use GTK::Simple::App;
use GTK::Simple::Frame;

#------------------------------------------------------------------------------
my $app = GTK::Simple::App.new( :title("Hello GTK!"), :width(10), :height(10));

my GTK::Simple::Button $b1 .= new(:label("Hello World!"));
my GTK::Simple::Button $b2 .= new(:label("Goodbye!"));
my GTK::Simple::HBox $hbox .= new;
$hbox.spacing(2);
$hbox.pack-start( $b1, False, False, 2);
$hbox.pack-start( $b2, False, False, 2);

my GTK::Simple::VBox $vbox .= new;
$vbox.pack-start( $hbox, False, False, 2);

my GTK::Simple::Frame $f1 .= new(:label('top level buttons'));
$f1.set-content($vbox);
#$f1.size-request( $b1.width() + 2, $b1.height * 2 + 4);

$app.set-content($f1);
$app.border-width = 1;
#$app.size-request( 1000, 80);

$b2.sensitive = False;
$b1.clicked.tap(-> $widget { change-states($widget); });
$b2.clicked.tap(-> $widget { exit-app($widget); });

$app.run;

#------------------------------------------------------------------------------
sub exit-app( $widget ) {
  note $widget.perl;
  $app.exit;
}

#------------------------------------------------------------------------------
sub change-states ( $widget ) {
  $widget.sensitive = False;
  $b2.sensitive = True;
}
