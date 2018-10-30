#!/usr/bin/env perl6

use v6;
use lib 'lib';
use GTK::Simpler;

my $app = app( :title( 'More widgets') );

my %texts = <blue red> Z=>
    '<span foreground="blue" size="x-large">Blue text</span> is <i>cool</i>!',
    '<span foreground="red" size="x-large">Red text</span> is <b>hot</b>!'
;

$app.set-content(
    vbox( 
        hbox(
            vbox( 
                my $normal-label          = label(:text("Normal label: %texts<blue>" ) ),
                my $marked-label          = label(:text("Label with markup: %texts<blue>") ),
                my $bR                    = check-button(:label('Make Red')),
                my $bB                    = toggle-button(:label('Make Blue')),
                my $label-for-vertical    = markup-label(:text('Vertical scale value is:')),
                my $label-for-horizontal  = markup-label(:text('Horizontal scale value is:')),
            ),
            my $scale-vertical = scale(:orientation<vertical>, :max(31), :min(2.4), :step(0.3), :value(21) ),
        ),
        my $scale-horizontal = scale
    )
);

sub make-blue($b) {
    $normal-label.text = "Normal label: %texts<blue>";
    $marked-label.text = "Label with markup: %texts<blue>";
}

sub make-red($b) {
    $normal-label.text = "Normal label: %texts<red>";
    $marked-label.text = "Label with markup: %texts<red>";
}

sub vertical-changes($b) {
    $label-for-vertical.text = 'Number is <span foreground="green" size="large">' ~ $scale-vertical.value ~'</span>';
}

sub horizontal-changes($b) {
    $label-for-horizontal.text = 'Number is <span foreground="green" size="large">' ~ $scale-horizontal.value ~'</span>';
}

$bB.toggled.tap: &make-blue;
$bR.toggled.tap: &make-red;
$scale-vertical.value-changed.tap: &vertical-changes;

$scale-horizontal.value-changed.tap: &horizontal-changes;

$app.run;
