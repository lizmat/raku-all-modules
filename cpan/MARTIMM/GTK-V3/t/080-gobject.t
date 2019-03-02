use v6;
use NativeCall;
use Test;

use GTK::V3::X;
use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GValue;
use GTK::V3::Glib::GType;
use GTK::V3::Gtk::GtkLabel;

#-------------------------------------------------------------------------------
subtest 'properties of label', {

  my GTK::V3::Glib::GType $gt .= new;
  my GTK::V3::Glib::GValue $gv .= new(:init(G_TYPE_STRING));
  is $gt.g-type-check-value($gv()), 1, 'gvalue initialized';

  my GTK::V3::Gtk::GtkLabel $label1 .= new(:label('abc def'));
  is $label1.gtk-label-get-text, 'abc def', 'label text set';

  $label1.g-object-get-property( 'label', $gv);
  is $gv.g-value-get-string, 'abc def', 'label property matches with text';

  $gv.g-value-set-string('pqr xyz');
  $label1.g-object-set-property( 'label', $gv);
  is $label1.gtk-label-get-text, 'pqr xyz',
     'label text modified using property ';

  $gv.g-value-unset;

  $gv .= new(:init(G_TYPE_INT));
  $label1.get-property( 'lines', $gv);
  is $gv.get-int, -1, 'default lines property set to -1';

  $gv.g-value-unset;
}

#-------------------------------------------------------------------------------
done-testing;
