#!/usr/bin/env perl6

use v6;

use lib 'lib';
use GTK::Simpler;
use GTK::Simple::Toolbar;

my $app = app(title => "Toolbar Demo");

my $toolbar = toolbar;
$toolbar.add-menu-item(
    my $new-toolbar-button  = menu-tool-button(:icon(GTK_STOCK_NEW))
);
$toolbar.add-menu-item(
    my $open-toolbar-button = menu-tool-button(:icon(GTK_STOCK_OPEN))
);
$toolbar.add-menu-item(
    my $save-toolbar-button = menu-tool-button(:icon(GTK_STOCK_SAVE))
);
$toolbar.add-separator;
$toolbar.add-menu-item(
    my $exit-toolbar-button = menu-tool-button(:icon(GTK_STOCK_QUIT))
);

my $toolbar-vbox  = $toolbar.pack;
my $bottom-button = button(:label("Bottom space")),

$app.set-content(
    vbox(
        [
            { :widget($toolbar-vbox), :expand(False) },
            $bottom-button
        ]
    )
);

$new-toolbar-button.clicked.tap: {
    "New toolbar button clicked".say;
}
$open-toolbar-button.clicked.tap: {
    "Open toolbar button clicked".say;
}
$save-toolbar-button.clicked.tap: {
    "Save toolbar button clicked".say;
}
$exit-toolbar-button.clicked.tap: {
    $app.exit;
}

$app.show-all;
$app.run;
