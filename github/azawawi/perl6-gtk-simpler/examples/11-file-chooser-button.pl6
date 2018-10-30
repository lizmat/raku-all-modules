#!/usr/bin/env perl6

use v6;

use lib 'lib';
use GTK::Simpler;

my $app                  = app(:title("File Chooser Demo"));
my $text-view            = text-view;
my $file-chooser-button  = file-chooser-button(
    :title("Please Select a File")
);

$file-chooser-button.file-set.tap: {
    $text-view.text ~= $file-chooser-button.file-name ~ "\n";
}

$app.set-content(
    vbox([
        { :widget($file-chooser-button), :expand(False) },
        $text-view,
    ])
);

$app.show;
$app.run;
