#!/usr/bin/env perl6

use v6.c;
use lib 'lib';
use GTK::Simpler;

my $app          = app(title=> 'Example 17');
my $send-history = text-view(text=>'Old stuff');
my $flood-data   = toggle-button(label=>'Flood with stuff');
my $exit-b       = toggle-button(label=>'Exit');

my $scrolled     = scrolled-window;
$scrolled.set-content( $send-history );

my $v            = vbox( 
    $flood-data,
    $scrolled,
    $exit-b
);

$flood-data.toggled.tap: -> $b { 
    my $s = 'Twas brillig and the slithy toothes did gyre and gymbol';
    for ^25 { $send-history.text ~= (' ' x $_) ~ "$s\n" }
};
$exit-b.toggled.tap(-> $b { $app.exit } );

$app.set-content( $v );
$app.border-width = 20;
$app.run;
