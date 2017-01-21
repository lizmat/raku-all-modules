Name
====

GTK::Simpler - A simpler & more efficient API for GTK::Simple

Synopsis
========

    use v6;
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

Description
===========

This module provides a simpler and more efficient API for [GTK::Simple](https://github.com/perl6/gtk-simple). The idea here is to load GTK::Simple widgets lazily at runtime and type less characters. For example instead of writing the following:

        # This is slow since it will load a lot of GTK::Simple widgets by default
        use GTK::Simple;

        my $app = GTK::Simple::App.new(title => "Hello");

you write the more concise shorter form:

    # Exports a bunch of subroutines by default
    use GTK::Simpler;

    # GTK::Simple::App is loaded and created only here
    my $app = app(title => "Hello");

Installation
============

Please check [GTK::Simple prerequisites](https://github.com/perl6/gtk-simple/blob/master/README.md#prerequisites) section for more information.

To install it using zef (a module management tool bundled with Rakudo Star):

    $ zef install GTK::Simpler

Subroutines
===========

The following routines are exported by default:

app
---

Returns a GTK::Simple::App object.

connection-handler
------------------

Returns a GTK::Simple::ConnectionHandler object.

widget
------

Returns a GTK::Simple::Widget object.

container
---------

Returns a GTK::Simple::Container object.

window
------

Returns a GTK::Simple::Window object.

scheduler
---------

Returns a GTK::Simple::Scheduler object.

box
---

Returns a GTK::Simple::Box object.

hbox
----

Returns a GTK::Simple::HBox object.

vbox
----

Returns a GTK::Simple::VBox object.

grid
----

Returns a GTK::Simple::Grid object.

label
-----

Returns a GTK::Simple::Label object.

markup-label
------------

Returns a GTK::Simple::MarkUpLabel object.

scale
-----

Returns a GTK::Simple::Scale object.

entry
-----

Returns a GTK::Simple::Entry object.

text-view
---------

Returns a GTK::Simple::TextView object.

button
------

Returns a GTK::Simple::Button object.

toggle-button
-------------

Returns a GTK::Simple::ToggleButton object.

check-button
------------

Returns a GTK::Simple::CheckButton object.

drawing-area
------------

Returns a GTK::Simple::DrawingArea object.

switch
------

Returns a GTK::Simple::Switch object.

status-bar
----------

Returns a GTK::Simple::StatusBar object.

separator
---------

Returns a GTK::Simple::Separator object.

progress-bar
------------

Returns a GTK::Simple::ProgressBar object.

frame
-----

Returns a GTK::Simple::Frame object.

combo-box-text
--------------

Returns a GTK::Simple::ComboBoxText object.

action-bar
----------

Returns a GTK::Simple::ActionBar object.

spinner
-------

Returns a GTK::Simple::Spinner object.

toolbar
-------

Returns a GTK::Simple::Toolbar object.

menu-tool-button
----------------

Returns a GTK::Simple::MenuToolButton object.

menu-item
---------

Returns a GTK::Simple::MenuToolButton object.

menu
----

Returns a GTK::Simple::Menu object.

menu-bar
--------

Returns a GTK::Simple::MenuBar object.

file-chooser-button
-------------------

Returns a GTK::Simple::FileChooserButton object.

places-sidebar
--------------

Returns a GTK::Simple::PlacesSidebar object.

radio-button
------------

Returns a GTK::Simple::RadioButton object.

link-button
-----------

Returns a GTK::Simple::LinkButton object.

level-bar
---------

Returns a GTK::Simple::LevelBar object.

scrolled-window
---------------

Returns a GTK::Simple::ScrolledWindow object.

See also
========

[GTK::Simple](https://github.com/perl6/gtk-simple)

Author
======

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi) on #perl6

Copyright and license
=====================

Copyright 2016-2017 Ahmad M. Zawawi under the MIT License
