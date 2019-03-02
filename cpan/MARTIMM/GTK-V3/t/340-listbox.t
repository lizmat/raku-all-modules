use v6;
use NativeCall;
use Test;

use GTK::V3::Glib::GList;
use GTK::V3::Gtk::GtkListBox;
use GTK::V3::Gtk::GtkGrid;
use GTK::V3::Gtk::GtkCheckButton;
use GTK::V3::Gtk::GtkLabel;

#-------------------------------------------------------------------------------
subtest 'Listbox create', {

  diag "Prepare an entry in the listbox";
  my GTK::V3::Gtk::GtkListBox $list-box .= new(:empty);
  isa-ok $list-box, GTK::V3::Gtk::GtkListBox;

  my GTK::V3::Gtk::GtkGrid $grid .= new(:empty);
  $grid.set-visible(True);

  my GTK::V3::Gtk::GtkCheckButton $check .= new(:label('abc'));
  $check.set-visible(True);
  $grid.gtk-grid-attach( $check(), 0, 0, 1, 1);

  my GTK::V3::Gtk::GtkLabel $label .= new(:label('first entry'));
  $label.set-visible(True);
  $grid.gtk-grid-attach( $label(), 1, 0, 1, 1);

  $list-box.gtk-container-add($grid);

  diag "Check what is in the listbox";
  my GTK::V3::Glib::GList $gl .= new(:glist($list-box.get-children));
  is $gl.g-list-length, 1, 'One listbox row in listbox';
  my GTK::V3::Gtk::GtkBin $lb-row .= new(
    :widget($list-box.get-row-at-index(0))
  );
  my GTK::V3::Gtk::GtkGrid $lb-grid .= new(:widget($lb-row.get_child()));
  $gl .= new(:glist($lb-grid.get-children));
  is $gl.g-list-length, 2, 'Two entries in grid';

  my GTK::V3::Gtk::GtkCheckButton $lb-cb .= new(
    :widget($lb-grid.get-child-at( 0, 0))
  );
  is $lb-cb.get-label, 'abc', 'checkbox label found';
}

#-------------------------------------------------------------------------------
done-testing;
