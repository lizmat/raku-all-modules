use v6;
#use lib '../gtk-v3/lib';
use Test;

use GTK::Glade;

use GTK::V3::Glib::GObject;

use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkWidget;
use GTK::V3::Gtk::GtkButton;
use GTK::V3::Gtk::GtkLabel;

#-------------------------------------------------------------------------------
diag "\n";

my $dir = 'xt/x';
mkdir $dir unless $dir.IO ~~ :e;

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
my Str $ui-file = "$dir/a.xml";
$ui-file.IO.spurt(Q:q:to/EOXML/);
  <?xml version="1.0" encoding="UTF-8"?>
  <!-- Generated with glade 3.20.0 -->
  <interface>
    <requires lib="gtk+" version="3.0"/>
    <object class="GtkWindow" id="window">
      <property name="visible">True</property>
      <property name="can_focus">False</property>
      <property name="border_width">10</property>
      <property name="title">Glade Gui Read Test</property>
      <signal name="delete-event" handler="quit-program" swapped="no"/>
      <style>
        <class name="yellow"/>
      </style>
      <child>
        <object class="GtkGrid" id="grid">
          <property name="visible">True</property>
          <property name="can_focus">False</property>
          <child>
            <object class="GtkButton" id="button1">
              <property name="label">Button 1</property>
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="receives_default">False</property>
              <signal name="clicked" handler="hello-world1" swapped="no"/>
              <style>
                <class name="green"/>
                <class name="circular"/>
                <class name="flat"/>
              </style>
            </object>
            <packing>
              <property name="left_attach">0</property>
              <property name="top_attach">0</property>
            </packing>
          </child>
          <child>
            <object class="GtkButton" id="button2">
              <property name="label">Button 2</property>
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="receives_default">False</property>
              <signal name="clicked" handler="hello-world2" swapped="no"/>
              <style>
                <class name="green"/>
                <class name="circular"/>
              </style>
            </object>
            <packing>
              <property name="left_attach">1</property>
              <property name="top_attach">0</property>
            </packing>
          </child>
          <child>
            <object class="GtkButton" id="quit">
              <property name="label">Quit</property>
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="receives_default">False</property>
              <signal name="clicked" handler="quit-program" swapped="no"
                      object="button2" after="yes"/>
              <style>
                <class name="yellow"/>
                <class name="circular"/>
              </style>
            </object>
            <packing>
              <property name="left_attach">0</property>
              <property name="top_attach">1</property>
              <property name="width">2</property>
            </packing>
          </child>
        </object>
      </child>
    </object>
  </interface>
  EOXML


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
my Str $css-file = "$dir/a.css";
$css-file.IO.spurt(Q:q:to/EOXML/);

  .green {
    color:            #a0f0cc;
    background-color: #308f8f;
    font:             25px sans;
  }

  .yellow {
    color:            #ffdf10;
    background-color: #806000;
    font:             25px sans;
  }

  EOXML

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
class E is GTK::Glade::Engine {

  #-----------------------------------------------------------------------------
  method quit-program ( :widget($button), :$target-widget-name ) {
    diag "quit-program called";
    diag "Widget: " ~ $button.perl;
    diag "Target name: " ~ $target-widget-name.perl if ?$target-widget-name;

    # in the glade design the name is not set and by default the type name
    my Str $bn = $button.get-name;
    if $bn eq 'GtkButton' {
      is $button.get-label, "Quit", "Label of quit button ok";
    }

    else {
      is $bn, 'GtkWindow', "name of button is same as class name 'GtkWindow'";
    }

    self.glade-main-quit();
  }

  #-----------------------------------------------------------------------------
  method hello-world1 ( :widget($button), :$target-widget-name ) {

    is $button.get-label, "Button 1", "Label of button 1 ok";

    my Str $bn = $button.get-name;
    is $bn, 'GtkButton', "name of button is class name 'GtkButton'";

    $button.set-name("HelloWorld1Button");
    $bn = $button.get-name;
    is $bn, 'HelloWorld1Button', "name changed into 'HelloWorld1Button'";

    # Change back to keep test ok for next click of the button
    $button.set-name("GtkButton");
  }

  #-----------------------------------------------------------------------------
  method hello-world2 ( :widget($button), :$target-widget-name ) {
    is $button.get-label, "Button 2", "Label of button 2 ok";
  }
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
subtest 'Action object', {
  my E $engine .= new();

  my GTK::Glade $gui .= new;
  isa-ok $gui, GTK::Glade, 'type ok';
  $gui.add-gui-file($ui-file);
  $gui.add-css($css-file);
  $gui.add-engine(E.new);
  $gui.run;
}

#-------------------------------------------------------------------------------
done-testing;

unlink $ui-file;
unlink $css-file;
rmdir $dir;
