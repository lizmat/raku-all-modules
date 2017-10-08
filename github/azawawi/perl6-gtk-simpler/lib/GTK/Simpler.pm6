use v6;

unit module GTK::Simpler;

=begin pod

=head1 Name

GTK::Simpler - A simpler & more efficient API for GTK::Simple

=head1 Synopsis

=begin code
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
=end code

=head1 Description

This module provides a simpler and more efficient API for
L<GTK::Simple|https://github.com/perl6/gtk-simple>. The idea here is to load
GTK::Simple widgets lazily at runtime and type less characters. For example
instead of writing the following:

=begin code
    # This is slow since it will load a lot of GTK::Simple widgets by default
    use GTK::Simple;

    my $app = GTK::Simple::App.new(title => "Hello");
=end code

you write the more concise shorter form:

=begin code
# Exports a bunch of subroutines by default
use GTK::Simpler;

# GTK::Simple::App is loaded and created only here
my $app = app(title => "Hello");
=end code

=head1 Installation

Please check L<GTK::Simple prerequisites|https://github.com/perl6/gtk-simple/blob/master/README.md#prerequisites>
section for more information.

To install it using zef (a module management tool bundled with Rakudo Star):

=begin code
$ zef install GTK::Simpler
=end code

=head1 Subroutines

The following routines are exported by default:

=end pod

=begin pod
=head2 app

Returns a GTK::Simple::App object.
=end pod
sub app(|args) is export {
    require GTK::Simple::App;
    return ::('GTK::Simple::App').new(|args);
}

=begin pod
=head2 connection-handler

Returns a GTK::Simple::ConnectionHandler object.
=end pod
sub connection-handler(|args) is export {
    require GTK::Simple::ConnectionHandler;
    return ::('GTK::Simple::ConnectionHandler').new(|args);
}

=begin pod
=head2 widget

Returns a GTK::Simple::Widget object.
=end pod
sub widget(|args) is export {
    require GTK::Simple::Widget;
    return ::('GTK::Simple::Widget').new(|args);
}

=begin pod
=head2 container

Returns a GTK::Simple::Container object.
=end pod
sub container(|args) is export {
    require GTK::Simple::Container;
    return ::('GTK::Simple::Container').new(|args);
}

=begin pod
=head2 window

Returns a GTK::Simple::Window object.
=end pod
sub window(|args) is export {
    require GTK::Simple::Window;
    return ::('GTK::Simple::Window').new(|args);
}

=begin pod
=head2 scheduler

Returns a GTK::Simple::Scheduler object.
=end pod
sub scheduler(|args) is export {
    require GTK::Simple::Scheduler;
    return ::('GTK::Simple::Scheduler').new(|args);
}

=begin pod
=head2 box

Returns a GTK::Simple::Box object.
=end pod
sub box(|args) is export {
    require GTK::Simple::Box;
    return ::('GTK::Simple::Box').new(|args);
}

=begin pod
=head2 hbox

Returns a GTK::Simple::HBox object.
=end pod
sub hbox(|args) is export {
    require GTK::Simple::HBox;
    return ::('GTK::Simple::HBox').new(|args);
}

=begin pod
=head2 vbox

Returns a GTK::Simple::VBox object.
=end pod
sub vbox(|args) is export {
    require GTK::Simple::VBox;
    return ::('GTK::Simple::VBox').new(|args);
}

=begin pod
=head2 grid

Returns a GTK::Simple::Grid object.
=end pod
sub grid(|args) is export {
    require GTK::Simple::Grid;
    return ::('GTK::Simple::Grid').new(|args);
}

=begin pod
=head2 label

Returns a GTK::Simple::Label object.
=end pod
sub label(|args) is export {
    require GTK::Simple::Label;
    return ::('GTK::Simple::Label').new(|args);
}

=begin pod
=head2 markup-label

Returns a GTK::Simple::MarkUpLabel object.
=end pod
sub markup-label(|args) is export {
    require GTK::Simple::MarkUpLabel;
    return ::('GTK::Simple::MarkUpLabel').new(|args);
}

=begin pod
=head2 scale

Returns a GTK::Simple::Scale object.
=end pod
sub scale(|args) is export {
    require GTK::Simple::Scale;
    return ::('GTK::Simple::Scale').new(|args);

}

=begin pod
=head2 entry

Returns a GTK::Simple::Entry object.
=end pod
sub entry(|args) is export {
    require GTK::Simple::Entry;
    return ::('GTK::Simple::Entry').new(|args);
}

=begin pod
=head2 text-view

Returns a GTK::Simple::TextView object.
=end pod
sub text-view(|args) is export {
    require GTK::Simple::TextView;
    return ::('GTK::Simple::TextView').new(|args);

}

=begin pod
=head2 button

Returns a GTK::Simple::Button object.
=end pod
sub button(|args) is export {
    require GTK::Simple::Button;
    return ::('GTK::Simple::Button').new(|args);
}

=begin pod
=head2 toggle-button

Returns a GTK::Simple::ToggleButton object.
=end pod
sub toggle-button(|args) is export {
    require GTK::Simple::ToggleButton;
    return ::('GTK::Simple::ToggleButton').new(|args);
}

=begin pod
=head2 check-button

Returns a GTK::Simple::CheckButton object.
=end pod
sub check-button(|args) is export {
    require GTK::Simple::CheckButton;
    return ::('GTK::Simple::CheckButton').new(|args);
}

=begin pod
=head2 drawing-area

Returns a GTK::Simple::DrawingArea object.
=end pod
sub drawing-area(|args) is export {
    require GTK::Simple::DrawingArea;
    return ::('GTK::Simple::DrawingArea').new(|args);
}

=begin pod
=head2 switch

Returns a GTK::Simple::Switch object.
=end pod
sub switch(|args) is export {
    require GTK::Simple::Switch;
    return ::('GTK::Simple::Switch').new(|args);
}

=begin pod
=head2 status-bar

Returns a GTK::Simple::StatusBar object.
=end pod
sub status-bar(|args) is export {
    require GTK::Simple::StatusBar;
    return ::('GTK::Simple::StatusBar').new(|args);
}

=begin pod
=head2 separator

Returns a GTK::Simple::Separator object.
=end pod
sub separator(|args) is export {
    require GTK::Simple::Separator;
    return ::('GTK::Simple::Separator').new(|args);
}

=begin pod
=head2 progress-bar

Returns a GTK::Simple::ProgressBar object.
=end pod
sub progress-bar(|args) is export {
    require GTK::Simple::ProgressBar;
    return ::('GTK::Simple::ProgressBar').new(|args);
}

=begin pod
=head2 frame

Returns a GTK::Simple::Frame object.
=end pod
sub frame(|args) is export {
    require GTK::Simple::Frame;
    return ::('GTK::Simple::Frame').new(|args);
}

=begin pod
=head2 combo-box-text

Returns a GTK::Simple::ComboBoxText object.
=end pod
sub combo-box-text(|args) is export {
    require GTK::Simple::ComboBoxText;
    return ::('GTK::Simple::ComboBoxText').new(|args);
}

=begin pod
=head2 action-bar

Returns a GTK::Simple::ActionBar object.
=end pod
sub action-bar(|args) is export {
    require GTK::Simple::ActionBar;
    return ::('GTK::Simple::ActionBar').new(|args);
}

=begin pod
=head2 spinner

Returns a GTK::Simple::Spinner object.
=end pod
sub spinner(|args) is export {
    require GTK::Simple::Spinner;
    return ::('GTK::Simple::Spinner').new(|args);
}

=begin pod
=head2 toolbar

Returns a GTK::Simple::Toolbar object.
=end pod
sub toolbar(|args) is export {
    require GTK::Simple::Toolbar;
    return ::('GTK::Simple::Toolbar').new(|args);
}

=begin pod
=head2 menu-tool-button

Returns a GTK::Simple::MenuToolButton object.
=end pod
sub menu-tool-button(|args) is export {
    require GTK::Simple::MenuToolButton;
    return ::('GTK::Simple::MenuToolButton').new(|args);
}

=begin pod
=head2 menu-item

Returns a GTK::Simple::MenuToolButton object.
=end pod
sub menu-item(|args) is export {
    require GTK::Simple::MenuItem;
    return ::('GTK::Simple::MenuItem').new(|args);
}

=begin pod
=head2 menu

Returns a GTK::Simple::Menu object.
=end pod
sub menu(|args) is export {
    require GTK::Simple::Menu;
    return ::('GTK::Simple::Menu').new(|args);
}

=begin pod
=head2 menu-bar

Returns a GTK::Simple::MenuBar object.
=end pod
sub menu-bar(|args) is export {
    require GTK::Simple::MenuBar;
    return ::('GTK::Simple::MenuBar').new(|args);
}

=begin pod
=head2 file-chooser-button

Returns a GTK::Simple::FileChooserButton object.
=end pod
sub file-chooser-button(|args) is export {
    require GTK::Simple::FileChooserButton;
    return ::('GTK::Simple::FileChooserButton').new(|args);
}

=begin pod
=head2 places-sidebar

Returns a GTK::Simple::PlacesSidebar object.

=end pod
sub places-sidebar(|args) is export {
    require GTK::Simple::PlacesSidebar;
    return ::('GTK::Simple::PlacesSidebar').new(|args);
}

=begin pod
=head2 radio-button

Returns a GTK::Simple::RadioButton object.
=end pod
sub radio-button(|args) is export {
    require GTK::Simple::RadioButton;
    return ::('GTK::Simple::RadioButton').new(|args);
}

=begin pod
=head2 link-button

Returns a GTK::Simple::LinkButton object.
=end pod
sub link-button(|args) is export {
    require GTK::Simple::LinkButton;
    return ::('GTK::Simple::LinkButton').new(|args);
}

=begin pod
=head2 level-bar

Returns a GTK::Simple::LevelBar object.
=end pod
sub level-bar(|args) is export {
    require GTK::Simple::LevelBar;
    return ::('GTK::Simple::LevelBar').new(|args);
}

=begin pod
=head2 scrolled-window

Returns a GTK::Simple::ScrolledWindow object.
=end pod
sub scrolled-window(|args) is export {
    require GTK::Simple::ScrolledWindow;
    return ::('GTK::Simple::ScrolledWindow').new(|args);
}

=begin pod

=head1 See also

L<GTK::Simple|https://github.com/perl6/gtk-simple>

=head1 Author

Ahmad M. Zawawi, L<azawawi|https://github.com/azawawi> on #perl6

=head1 Copyright and license

Copyright 2016-2017 Ahmad M. Zawawi under the MIT License

=end pod
