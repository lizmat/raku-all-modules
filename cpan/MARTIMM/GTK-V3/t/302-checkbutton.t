use v6;
use NativeCall;
use Test;

use GTK::V3::Gtk::GtkWidget;
use GTK::V3::Gtk::GtkCheckButton;

diag "\n";


#-------------------------------------------------------------------------------
subtest 'CheckButton create', {

  my GTK::V3::Gtk::GtkCheckButton $cb .= new(:label('abc'));
  isa-ok $cb, GTK::V3::Gtk::GtkCheckButton;
}

#-------------------------------------------------------------------------------
done-testing;
