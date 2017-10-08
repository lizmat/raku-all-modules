#!/usr/bin/env perl6

use v6;
use lib 'lib';
use GTK::Simpler;

my $app = app(title => "Hello GTK!");

$app.set-content(
    vbox(
        my $first-button  = button(label => "Hello World!"),
        my $second-button = button(label => "Goodbye!")
    )
);

$app.border-width        = 20;
$second-button.sensitive = False;

$first-button.clicked.tap({ 
    .sensitive = False; 
    $second-button.sensitive = True 
});

$second-button.clicked.tap({ 
    $app.exit; 
});

$app.run;
