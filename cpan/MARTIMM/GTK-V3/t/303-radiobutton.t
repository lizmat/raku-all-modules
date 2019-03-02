use v6;
use NativeCall;
use Test;

use GTK::V3::Glib::GSList;
use GTK::V3::Gtk::GtkWidget;
use GTK::V3::Gtk::GtkRadioButton;

diag "\n";


#-------------------------------------------------------------------------------
subtest 'RadioButton create', {

  diag "create radio button";
  my GTK::V3::Gtk::GtkRadioButton $rb1 .= new(:label('abc'));
  isa-ok $rb1, GTK::V3::Gtk::GtkRadioButton;

  diag "2nd radio button gets inserted at the front of the group list";
  my GTK::V3::Gtk::GtkRadioButton $rb2 .= new(:group-from($rb1));

  diag "set label on 2nd button with GtkButton method";
  $rb2.set-label('rb2');
  is $rb2.get-label, 'rb2', 'label of 2nd button is ok';

  diag "test active button";
  is $rb1.get-active, 1, '1st button is selected';
  is $rb2.get-active, 0, '2nd button is not selected';

  diag "set 2nd button active";
  $rb2.set-active(1);
  is $rb1.get-active, 0, '1st button is not selected';
  is $rb2.get-active, 1, '2nd button is selected';
}

#-------------------------------------------------------------------------------
subtest 'RadioButton group list', {

  my GTK::V3::Gtk::GtkRadioButton $rb1 .= new(:label<rb1>);
  my GTK::V3::Gtk::GtkRadioButton $rb2 .= new( :group-from($rb1), :label<rb2>);

  diag "get group list";
  my GTK::V3::Glib::GSList $l .= new(:gslist($rb2.get-group));
  is $l.g-slist-length, 2, 'group has two members';

  diag "test button labels";
  my GTK::V3::Gtk::GtkRadioButton $b .= new(:widget($l.nth-data-gobject(1)));
  is $b.get-label, 'rb1', 'found label from 1st radio button';
  $b .= new(:widget($l.nth-data-gobject(0)));
  is $b.get-label, 'rb2', 'found label from 2nd radio button';
}

#-------------------------------------------------------------------------------
done-testing;
