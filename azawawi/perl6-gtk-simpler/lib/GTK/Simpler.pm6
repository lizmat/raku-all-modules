use v6;

unit module GTK::Simpler;

sub app(|args) is export {
    require GTK::Simple::App;
    return ::('GTK::Simple::App').new(|args);
}

sub connection-handler(|args) is export {
    require GTK::Simple::ConnectionHandler;
    return ::('GTK::Simple::ConnectionHandler').new(|args);
}

sub widget(|args) is export {
    require GTK::Simple::Widget;
    return ::('GTK::Simple::Widget').new(|args);
}

sub container(|args) is export {
    require GTK::Simple::Container;
    return ::('GTK::Simple::Container').new(|args);
}

sub window(|args) is export {
    require GTK::Simple::Window;
    return ::('GTK::Simple::Window').new(|args);
}

sub scheduler(|args) is export {
    require GTK::Simple::Scheduler;
    return ::('GTK::Simple::Scheduler').new(|args);
}

sub box(|args) is export {
    require GTK::Simple::Box;
    return ::('GTK::Simple::Box').new(|args);
}

sub hbox(|args) is export {
    require GTK::Simple::HBox;
    return ::('GTK::Simple::HBox').new(|args);
}

sub vbox(|args) is export {
    require GTK::Simple::VBox;
    return ::('GTK::Simple::VBox').new(|args);
}

sub grid(|args) is export {
    require GTK::Simple::Grid;
    return ::('GTK::Simple::Grid').new(|args);
}

sub label(|args) is export {
    require GTK::Simple::Label;
    return ::('GTK::Simple::Label').new(|args);
}

sub markup-label(|args) is export {
    require GTK::Simple::MarkUpLabel;
    return ::('GTK::Simple::MarkUpLabel').new(|args);
}

sub scale(|args) is export {
    require GTK::Simple::Scale;
    return ::('GTK::Simple::Scale').new(|args);

}
sub entry(|args) is export {
    require GTK::Simple::Entry;
    return ::('GTK::Simple::Entry').new(|args);
}

sub text-view(|args) is export {
    require GTK::Simple::TextView;
    return ::('GTK::Simple::TextView').new(|args);

}
sub button(|args) is export {
    require GTK::Simple::Button;
    return ::('GTK::Simple::Button').new(|args);
}

sub toggle-button(|args) is export {
    require GTK::Simple::ToggleButton;
    return ::('GTK::Simple::ToggleButton').new(|args);
}

sub check-button(|args) is export {
    require GTK::Simple::CheckButton;
    return ::('GTK::Simple::CheckButton').new(|args);
}

sub drawing-area(|args) is export {
    require GTK::Simple::DrawingArea;
    return ::('GTK::Simple::DrawingArea').new(|args);
}

sub switch(|args) is export {
    require GTK::Simple::Switch;
    return ::('GTK::Simple::Switch').new(|args);
}

sub status-bar(|args) is export {
    require GTK::Simple::StatusBar;
    return ::('GTK::Simple::StatusBar').new(|args);
}

sub separator(|args) is export {
    require GTK::Simple::Separator;
    return ::('GTK::Simple::Separator').new(|args);
}

sub progress-bar(|args) is export {
    require GTK::Simple::ProgressBar;
    return ::('GTK::Simple::ProgressBar').new(|args);
}

sub frame(|args) is export {
    require GTK::Simple::Frame;
    return ::('GTK::Simple::Frame').new(|args);
}

sub combo-box-text(|args) is export {
    require GTK::Simple::ComboBoxText;
    return ::('GTK::Simple::ComboBoxText').new(|args);
}

sub action-bar(|args) is export {
    require GTK::Simple::ActionBar;
    return ::('GTK::Simple::ActionBar').new(|args);
}

sub spinner(|args) is export {
    require GTK::Simple::Spinner;
    return ::('GTK::Simple::Spinner').new(|args);
}

=begin doc

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

To install it using Panda (a module management tool bundled with Rakudo Star):

=begin code
$ panda update
$ panda install GTK::Simpler
=end code

=head1 Subroutines

The following routines are exported by default:

=head2 app

Returns a GTK::Simple::App object.

=head2 connection-handler

Returns a GTK::Simple::ConnectionHandler object.

=head2 widget

Returns a GTK::Simple::Widget object.

=head2 container

Returns a GTK::Simple::Container object.

=head2 window

Returns a GTK::Simple::Window object.

=head2 scheduler

Returns a GTK::Simple::Scheduler object.

=head2 box

Returns a GTK::Simple::Box object.

=head2 hbox

Returns a GTK::Simple::HBox object.

=head2 vbox

Returns a GTK::Simple::VBox object.

=head2 grid

Returns a GTK::Simple::Grid object.

=head2 label

Returns a GTK::Simple::Label object.

=head2 markup-label

Returns a GTK::Simple::MarkUpLabel object.

=head2 scale

Returns a GTK::Simple::Scale object.

=head2 entry

Returns a GTK::Simple::Entry object.

=head2 text-view

Returns a GTK::Simple::TextView object.

=head2 button

Returns a GTK::Simple::Button object.

=head2 toggle-button

Returns a GTK::Simple::ToggleButton object.

=head2 check-button

Returns a GTK::Simple::CheckButton object.

=head2 drawing-area

Returns a GTK::Simple::DrawingArea object.

=head2 switch

Returns a GTK::Simple::Switch object.

=head2 status-bar

Returns a GTK::Simple::StatusBar object.

=head2 separator

Returns a GTK::Simple::Separator object.

=head2 progress-bar

Returns a GTK::Simple::ProgressBar object.

=head2 frame

Returns a GTK::Simple::Frame object.

=head2 combo-box-text

Returns a GTK::Simple::ComboBoxText object.

=head2 action-bar

Returns a GTK::Simple::ActionBar object.

=head2 spinner

Returns a GTK::Simple::Spinner object.

=head1 See also

L<GTK::Simple|https://github.com/perl6/gtk-simple>

=head1 Author

Ahmad M. Zawawi, L<azawawi|https://github.com/azawawi> on #perl6

=head1 Copyright and license

Copyright 2016 Ahmad M. Zawawi under the MIT License

=end doc
