use v6;
use NativeCall;
use Test;

use GTK::V3::Glib::GObject;
use GTK::V3::X;
use GTK::V3::Gtk::GtkWidget;
use GTK::V3::Gtk::GtkBuilder;
use GTK::V3::Gtk::GtkLabel;

diag "\n";

#-------------------------------------------------------------------------------
subtest 'Label create', {

  my GTK::V3::Gtk::GtkLabel $label1 .= new(:label('abc def'));
  isa-ok $label1, GTK::V3::Gtk::GtkLabel;
  isa-ok $label1, GTK::V3::Gtk::GtkWidget;
  isa-ok $label1(), N-GObject;

  throws-like
    { $label1.get_nonvisible(); },
    X::GTK::V3, "non existent sub called",
    :message("Could not find native sub 'get_nonvisible\(...\)'");

  is $label1.get_visible, 0, "widget is invisible";
  $label1.gtk_widget_set-visible(True);
  is $label1.get-visible, 1, "widget set visible";

  is $label1.gtk_label_get_text, 'abc def',
    'label 1 text ok, read with $label1.gtk_label_get_text';

  my GTK::V3::Gtk::GtkLabel $label2 .= new(:label('pqr'));
  is $label2.gtk-label-get-text, 'pqr',
     'label 2 text o, read with $label1.gtk-label-get-text';
  $label1($label2());
  is $label1.get-text, 'pqr',
     'label 1 text replaced, read with $label1.get-text';
}

#-------------------------------------------------------------------------------
subtest 'Builder config', {

  my Str $cfg = q:to/EOTXT/;
    <?xml version="1.0" encoding="UTF-8"?>
    <!-- Generated with glade 3.22.1 -->
    <interface>
       <requires lib="gtk+" version="3.10"/>
       <object class="GtkLabel" id="copyLabel">
        <property name="label" translatable="yes">Text to copy</property>
        <attributes>
          <attribute name="weight" value="PANGO_WEIGHT_BOLD"/>
          <attribute name="background" value="red" start="5" end="10"/>
        </attributes>
      </object>
    </interface>
    EOTXT

  my GTK::V3::Gtk::GtkBuilder $builder .= new(:string($cfg));
  my GTK::V3::Gtk::GtkLabel $label .= new(:build-id<copyLabel>);
  is $label.get-text, "Text to copy", 'label text found from config';
}
#-------------------------------------------------------------------------------
done-testing;
