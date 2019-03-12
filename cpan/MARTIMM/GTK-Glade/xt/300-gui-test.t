use v6;
#use lib '../gtk-v3/lib';
use Test;

use GTK::Glade;
use GTK::Glade::Engine;

use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkWidget;
use GTK::V3::Gtk::GtkTextView;
use GTK::V3::Gtk::GtkButton;
use GTK::V3::Gtk::GtkLabel;

#-------------------------------------------------------------------------------
diag "\n";

my $dir = 'xt/x';
mkdir $dir unless $dir.IO ~~ :e;

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
my Str $file = "$dir/a.xml";
$file.IO.spurt(Q:q:to/EOXML/);
  <?xml version="1.0" encoding="UTF-8"?>
  <!-- Generated with glade 3.22.1 -->
  <interface>
    <requires lib="gtk+" version="3.10"/>
    <object class="GtkWindow" id="window">
      <property name="visible">True</property>
      <property name="can_focus">False</property>
      <property name="border_width">10</property>
      <property name="title">Grid</property>
      <child>
        <placeholder/>
      </child>
      <child>
        <object class="GtkGrid" id="grid">
          <property name="visible">True</property>
          <property name="can_focus">False</property>
          <property name="row_spacing">6</property>
          <property name="column_spacing">6</property>
          <child>
            <object class="GtkLabel" id="inputTxtLbl">
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="label" translatable="yes">Text to copy</property>
              <property name="justify">right</property>
              <property name="single_line_mode">True</property>
              <attributes>
                <attribute name="foreground" value="#f1f1a5fff0a0"/>
                <attribute name="background" value="#05058f8fa0a0"/>
              </attributes>
            </object>
            <packing>
              <property name="left_attach">0</property>
              <property name="top_attach">1</property>
            </packing>
          </child>
          <child>
            <object class="GtkTextView" id="inputTxt">
              <property name="visible">True</property>
              <property name="can_focus">True</property>
            </object>
            <packing>
              <property name="left_attach">1</property>
              <property name="top_attach">1</property>
              <property name="width">2</property>
            </packing>
          </child>
          <child>
            <object class="GtkButton" id="clearBttn">
              <property name="label" translatable="yes">Clear Text</property>
              <property name="visible">True</property>
              <property name="can_focus">True</property>
              <property name="receives_default">True</property>
              <signal name="clicked" handler="clear-text" swapped="no"/>
            </object>
            <packing>
              <property name="left_attach">0</property>
              <property name="top_attach">2</property>
            </packing>
          </child>
          <child>
            <object class="GtkButton" id="copyBttn">
              <property name="label">Copy Text</property>
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="receives_default">False</property>
              <signal name="clicked" handler="copy-text" swapped="no"/>
            </object>
            <packing>
              <property name="left_attach">1</property>
              <property name="top_attach">2</property>
            </packing>
          </child>
          <child>
            <object class="GtkButton" id="quitBttn">
              <property name="label">Quit</property>
              <property name="visible">True</property>
              <property name="can_focus">False</property>
              <property name="receives_default">False</property>
              <signal name="clicked" handler="exit-program" swapped="no"/>
            </object>
            <packing>
              <property name="left_attach">2</property>
              <property name="top_attach">2</property>
            </packing>
          </child>
          <child>
            <object class="GtkScrolledWindow" id="ScrolledOutputTxt">
              <property name="width_request">200</property>
              <property name="height_request">300</property>
              <property name="visible">True</property>
              <property name="can_focus">True</property>
              <property name="shadow_type">in</property>
              <property name="max_content_width">200</property>
              <property name="max_content_height">300</property>
              <child>
                <object class="GtkTextView" id="outputTxt">
                  <property name="width_request">200</property>
                  <property name="height_request">300</property>
                  <property name="visible">True</property>
                  <property name="can_focus">True</property>
                  <property name="wrap_mode">word</property>
                </object>
              </child>
            </object>
            <packing>
              <property name="left_attach">0</property>
              <property name="top_attach">0</property>
              <property name="width">3</property>
            </packing>
          </child>
        </object>
      </child>
    </object>
  </interface>
  EOXML

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
class E is GTK::Glade::Engine {

  #-----------------------------------------------------------------------------
  method exit-program ( ) {
#`{{
    diag "quit-program called";
    diag "Widget: " ~ $widget.perl if ?$widget;
    diag "Data: " ~ $data.perl if ?$data;
    diag "Object: " ~ $object.perl if ?$object;
}}
#note "LL 1c: ", gtk_main_level();
    self.glade-main-quit();
#note "LL 1d: ", gtk_main_level();
  }

  #-----------------------------------------------------------------------------
  method copy-text ( ) {

#note "copy text thread: $*THREAD.id()";
    my Str $text = self.glade-clear-text('inputTxt');
    self.glade-add-text( 'outputTxt', $text);
  }

  #-----------------------------------------------------------------------------
  method clear-text ( ) {

#note "clear text thread: $*THREAD.id()";
    self.glade-clear-text('outputTxt');
  }
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
class T does GTK::Glade::Engine::Test {

  #-----------------------------------------------------------------------------
  submethod BUILD ( ) {
    # Wait for start
    $!steps = [
#      :wait(1.2),

      # Test Copy button
      :native-gobject(:inputTxt<GTK::V3::Gtk::GtkTextView>),
      :do-test( {
          isa-ok $!widget, GTK::V3::Gtk::GtkTextView;
        }
      ),
      :set-text("text voor invoer\n"),
      :native-gobject(:copyBttn<GTK::V3::Gtk::GtkButton>),
      :emit-signal<clicked>,
#      :wait(1.0),
      :native-gobject(:outputTxt<GTK::V3::Gtk::GtkTextView>),
      :get-text,
      :do-test( {
          is $!text, "text voor invoer\n", 'Text found is same as input';
        }
      ),

      # Repeat test of Copy button
      :native-gobject(:inputTxt<GTK::V3::Gtk::GtkTextView>),
      :set-text("2e text\n"),
      :native-gobject(:copyBttn<GTK::V3::Gtk::GtkButton>),
      :emit-signal<clicked>,
#      :wait(1.0),
      :native-gobject(:outputTxt<GTK::V3::Gtk::GtkTextView>),
      :get-text,
      :do-test( {
          is $!text, "text voor invoer\n2e text\n",
             'Text is appended properly';
        }
      ),

      # Test Clear button
      :native-gobject(:clearBttn<GTK::V3::Gtk::GtkButton>),
      :emit-signal<clicked>,
#      :wait(1.0),
      :native-gobject(:outputTxt<GTK::V3::Gtk::GtkTextView>),
      :get-text,
      :do-test( {
          is $!text, "", 'Text is cleared';
        }
      ),

      # Test Quit button
      :do-test( {
          is self.glade-main-level, 1, 'loop level is 1';
        }
      ),
      :native-gobject(:quitBttn<GTK::V3::Gtk::GtkButton>),
      :emit-signal<clicked>,
#      :wait(5.0),
#      :do-test( {
#          is self.glade-main-level, 0, 'loop level is 0';
#        }
#      ),

      # Stop tests
#      :finish
    ];
  }
}

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
subtest 'Action object', {
  my GTK::Glade $gui .= new;
  isa-ok $gui, GTK::Glade, 'type ok';
  $gui.add-gui-file($file);
  $gui.add-engine(E.new);
  $gui.run(:test-setup(T.new()));
}

#-------------------------------------------------------------------------------
done-testing;

#unlink $file;
#rmdir $dir;
