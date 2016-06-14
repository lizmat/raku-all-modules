#!/usr/bin/env perl6

use v6;
use lib 'lib';
use GTK::Simpler;

my $app = app(title => "Combo Box");
$app.size-request(300,100);

my $combo = combo-box-text;

for <one two three four five six> -> $item {
    $combo.append-text("Entry " ~ $item);

}

$combo.set-active(5);

my $label = label(text => "not selected");

$combo.changed.tap({
    $label.text = $combo.active-text();
});

=comment preset the active item.

my $pre-set-combo = combo-box-text;
my @items = <zero one two three four five six>;

for @items -> $item {
    $pre-set-combo.append-text( $item )
}

$pre-set-combo.set-active( 3 );

my $lbl2 = label( text => @items[3] );

$pre-set-combo.changed.tap: { $lbl2.text = $pre-set-combo.active-text();  };


$app.set-content(vbox($label, $combo, $lbl2, $pre-set-combo));

$app.run;
