#!/usr/bin/env perl6

use v6;

use lib 'lib';
use GTK::Simpler;

my $app             = app(:title("Places Sidebar Demo"));
my $places-sidebar  = places-sidebar;

$places-sidebar.open-location.tap: {
    "open-location event triggered".say;
    #TODO get the location parameter
    # See https://developer.gnome.org/gtk3/stable/GtkPlacesSidebar.html#GtkPlacesSidebar-open-location)
}

my $show-trash-button = toggle-button( :label("Show Trash") );
$show-trash-button.toggled.tap: {
    $places-sidebar.show-trash = not $places-sidebar.show-trash;
};

my $show-recent-button = toggle-button( :label("Show Recent") );
$show-recent-button.toggled.tap: {
    $places-sidebar.show-recent = not $places-sidebar.show-recent;
};

my $show-desktop-button = toggle-button( :label("Show Desktop") );
$show-desktop-button.toggled.tap: {
    $places-sidebar.show-desktop = not $places-sidebar.show-desktop;
};

my $show-connect-to-server-button = toggle-button( 
    :label("Show Connect to Server") );
$show-connect-to-server-button.toggled.tap: {
    $places-sidebar.show-connect-to-server = 
        not $places-sidebar.show-connect-to-server;
};

my $show-other-locations-button = toggle-button(
    :label("Show Other Locations") );
$show-other-locations-button.toggled.tap: {
    $places-sidebar.show-other-locations = not $places-sidebar.show-other-locations;
};

# Update initial toggle button status
$show-trash-button.status             = $places-sidebar.show-trash;
$show-recent-button.status            = $places-sidebar.show-recent;
$show-desktop-button.status           = $places-sidebar.show-desktop;
$show-connect-to-server-button.status = $places-sidebar.show-connect-to-server;
$show-other-locations-button.status   = $places-sidebar.show-other-locations;

$app.set-content(
    hbox(
        $places-sidebar,
        vbox(
            $show-trash-button,
            $show-recent-button,
            $show-desktop-button,
            $show-connect-to-server-button,
            $show-other-locations-button,
        )
    )
);
$app.border-width = 20;

$app.run;
