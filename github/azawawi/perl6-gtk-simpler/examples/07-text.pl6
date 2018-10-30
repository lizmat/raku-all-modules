#!/usr/bin/env perl6

use v6;
use lib 'lib';
use GTK::Simpler;

my $app = app(title => 'Text');

my $editable        = check-button(label => 'Editable');
$editable.status    = True;
my $show-cursor     = check-button(label => 'Show Cursor');
$show-cursor.status = True;
my $monospace       = check-button(label => 'Monospaced');
$monospace.status   = False;
my $text-view       = text-view;

$editable.toggled.tap:    -> $w { $text-view.editable       = $w.status };
$show-cursor.toggled.tap: -> $w { $text-view.cursor-visible = $w.status };
$monospace.toggled.tap:   -> $w { $text-view.monospace      = $w.status };

my $vbox = vbox($editable, $show-cursor, $monospace, $text-view);

$app.set-content($vbox);

$app.run;
