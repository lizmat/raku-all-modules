#!/usr/bin/env perl6

use v6;

use lib 'lib';
use GTK::Simpler;


my $app = app(title => "Menu Bar Demo");

my $file-menu-item = menu-item(:label("File"));
$file-menu-item.set-sub-menu(
    my $file-menu = menu
);

my $quit-menu-item = menu-item(:label("Quit"));
$file-menu.append($quit-menu-item);

my $menu-bar = menu-bar;
$menu-bar.append($file-menu-item);

$quit-menu-item.activate.tap: {
    $app.exit;
}

my $vbox = $menu-bar.pack;
$app.set-content( $vbox );

$app.show-all;
$app.run;
