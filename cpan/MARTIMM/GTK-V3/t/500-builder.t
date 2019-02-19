use v6;
use Test;

use GTK::V3::Glib::GObject;
use GTK::V3::Gtk::GtkBuilder;

#-------------------------------------------------------------------------------
my $dir = 't/ui';
mkdir $dir unless $dir.IO ~~ :e;

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
my Str $ui-file = "$dir/ui.xml";
$ui-file.IO.spurt(Q:q:to/EOXML/);
  <?xml version="1.0" encoding="UTF-8"?>
  <!-- Generated with glade 3.22.1 -->
  <interface>
    <requires lib="gtk+" version="3.20"/>
    <object class="GtkWindow" id="window">
      <property name="can_focus">False</property>
      <child>
        <placeholder/>
      </child>
      <child>
        <object class="GtkButton" id="button">
          <property name="label" translatable="yes">button</property>
          <property name="visible">True</property>
          <property name="can_focus">True</property>
          <property name="receives_default">True</property>
        </object>
      </child>
    </object>
  </interface>
  EOXML


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
subtest 'Empty builder', {
  my GTK::V3::Gtk::GtkBuilder $builder;
  throws-like
    { $builder .= new; },
    X::GTK::V3, "No options used",
    :message('No options used to create or set the native widget');

  throws-like
    { $builder .= new( :build, :load); },
    X::GTK::V3, "Wrong options used",
    :message(
      /:s Unsupported options for
          'GTK::V3::Gtk::GtkBuilder:'
          [(build||load) ',']+/
    );

  $builder .= new(:empty);
  isa-ok $builder, GTK::V3::Gtk::GtkBuilder;
  isa-ok $builder(), N-GObject;
}

#-------------------------------------------------------------------------------
subtest 'Add ui from file to builder', {
  my GTK::V3::Gtk::GtkBuilder $builder .= new(:empty);

  my Int $e-code = $builder.add-from-file( $ui-file, Any);
  is $e-code, 1, "ui file added ok";

  my Str $text = $ui-file.IO.slurp;
  my N-GObject $b = $builder.new-from-string( $text, $text.chars);
  ok ?$b, 'builder is set';

  $builder .= new(:empty);
  $builder.add-gui(:filename($ui-file));
  ok ?$builder(), 'builder is added';

  $builder .= new(:empty);
  throws-like
    { $builder.add-gui(:filename('x.glade')); },
    X::GTK::V3, "non existent file added",
    :message("Error adding file 'x.glade' to the Gui");

  $builder .= new(:empty);
  # invalidate xml text
  $text ~~ s/ '<interface>' //;
  throws-like
    { $builder.add-gui(:string($text)); },
    X::GTK::V3, "erronenous xml file added",
    :message("Error adding xml text to the Gui");
}

#-------------------------------------------------------------------------------
done-testing;

unlink $ui-file;
rmdir $dir;
