use v6;
use NativeCall;
use Test;

use GTK::Glade::Gui;
use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkWidget;
use GTK::V3::Gtk::GtkLabel;

diag "\n";

# initialize
my GTK::V3::Gtk::GtkMain $main .= new;

#-------------------------------------------------------------------------------
subtest 'Label create', {

  my GTK::V3::Gtk::GtkLabel $label1 .= new(:text('abc def'));
  isa-ok $label1, GTK::V3::Gtk::GtkLabel;
  isa-ok $label1, GTK::V3::Gtk::GtkWidget;
  does-ok $label1, GTK::Glade::Gui;
  isa-ok $label1(), N-GtkWidget;

  throws-like
    { $label1.get_nonvisible(); },
    X::Gui, "non existent sub called",
    :message("Could not find native sub 'get_nonvisible\(...\)'");

  is $label1.get_visible, 0, "widget is invisible";
  $label1.gtk_widget_set-visible(True);
  is $label1.get-visible, 1, "widget set visible";

  is $label1.gtk_label_get_text, 'abc def',
    'label 1 text ok, read with $label1.gtk_label_get_text';

  my GTK::V3::Gtk::GtkLabel $label2 .= new(:text('pqr'));
  is $label2.gtk-label-get-text, 'pqr',
     'label 2 text o, read with $label1.gtk-label-get-text';
  $label1($label2());
  is $label1.get-text, 'pqr',
     'label 1 text replaced, read with $label1.get-text';
}

#-------------------------------------------------------------------------------
done-testing;
