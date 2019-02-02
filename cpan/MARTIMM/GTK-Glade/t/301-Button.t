use v6;
use NativeCall;
use Test;

use GTK::Glade::Gui;
use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkWidget;
use GTK::V3::Gtk::GtkButton;
use GTK::V3::Gtk::GtkLabel;

diag "\n";

# initialize
my GTK::V3::Gtk::GtkMain $main .= new;

#-------------------------------------------------------------------------------
subtest 'Button create', {

  my GTK::V3::Gtk::GtkButton $button1 .= new(:text('abc def'));
  isa-ok $button1, GTK::V3::Gtk::GtkButton;
  isa-ok $button1, GTK::V3::Gtk::GtkWidget;
  does-ok $button1, GTK::Glade::Gui;
  isa-ok $button1(), N-GtkWidget;

  throws-like
    { $button1.get-label('xyz'); },
    X::Gui, "wrong arguments",
    :message("Wrong call arguments to native sub 'get-label\(...\)'");

  is $button1.get-label, 'abc def', 'text on button ok';
  $button1.set-label('xyz');
  is $button1.get-label, 'xyz', 'text on button changed ok';
}

#-------------------------------------------------------------------------------
subtest 'Button as container', {
  my GTK::V3::Gtk::GtkButton $button1 .= new(:text('xyz'));
  my GTK::V3::Gtk::GtkLabel $l .= new(:text(''));
  $l($button1.get-children[0]);
  is $l.get-text, 'xyz', 'text label from button 1';

  my GTK::V3::Gtk::GtkLabel $label .= new(:text('pqr'));
  my GTK::V3::Gtk::GtkButton $button2 .= new;
  $button2.add($label());

  $l($button2.get-child);
  is $l.get-text, 'pqr', 'text label from button 2';

  # Next statement is not able to get the text directly
  # when gtk-container-add is used.
  is $button2.get-label, Str, 'text cannot be returned like this anymore';
}

#-------------------------------------------------------------------------------
done-testing;
