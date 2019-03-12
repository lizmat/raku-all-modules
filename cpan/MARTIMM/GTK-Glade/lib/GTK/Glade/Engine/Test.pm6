use v6;
use NativeCall;

use GTK::Glade::Engine;

use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GMain;
use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkBuilder;

#-------------------------------------------------------------------------------
unit role GTK::Glade::Engine::Test:auth<github:MARTIMM> is GTK::Glade::Engine;

# Must be set before by GTK::Glade::Engine::Work.glade-run().
has GTK::V3::Gtk::GtkBuilder $.builder is rw;

has GTK::V3::Gtk::GtkMain $!main;
has GTK::V3::Glib::GObject $!widget;
has Str $!text;
has Array $.steps;

#-------------------------------------------------------------------------------
# This method runs in a thread. Gui updates can be done using a context
method prepare-and-run-tests ( ) {

  my Promise $p = start {
    # wait for loop to start
    sleep(1.1);

    my GTK::V3::Glib::GMain $gmain .= new;
    my $main-context = $gmain.context-get-thread-default;

    $gmain.context-invoke(
      $main-context,
      -> $d {
        self!run-tests;
        0
      },
      OpaquePointer
    );

    'test done'
  }

  $!main.gtk_main();

  await $p;
  note $p.result;
}

#-------------------------------------------------------------------------------
method !run-tests ( ) {

  my Int $executed-tests = 0;

  if $!steps.elems {

    # clear data
    $!widget = GTK::V3::Glib::GObject;
    $!text = Str;

    for @$!steps -> Pair $substep {
      note "    Substep: $substep.key() => ",
            $substep.value() ~~ Block ?? 'Code block' !! $substep.value();

      given $substep.key {

        when 'native-gobject' {
          my Str $id = $substep.value.key;
          my Str $class = $substep.value.value;
          require ::($class);
          $!widget = ::($class).new(:build-id($id));
        }

        when 'emit-signal' {
          next unless ?$!widget;
          $!widget.emit-by-name-wd( $substep.value, $!widget(), OpaquePointer);
        }

        when 'get-text' {
          my GTK::V3::Gtk::GtkTextBuffer $buffer .= new(
            :widget($!widget.get-buffer)
          );
          $!text = $buffer.get-text(
            self.glade-start-iter($buffer), self.glade-end-iter($buffer), 1
          );
#            if ?$!widget and $!widget.get-has-window;
        }

        when 'set-text' {
          my GTK::V3::Gtk::GtkTextBuffer $buffer .= new(
            :widget($!widget.get-buffer)
          );
          $buffer.set-text( $substep.value, $substep.value.chars);
#            if ?$!widget and $!widget.get-has-window;
        }

        when 'do-test' {
          next unless $substep.value ~~ Block;

          $substep.value()();
          $executed-tests++;
        }

        when 'wait' {
          sleep $substep.value();
        }
      }

#note "LL 1a: ", gtk_main_level();
#      while gtk_events_pending() { gtk_main_iteration_do(False); }
#note "LL 1b: ", gtk_main_level();

      # Stop when loop is exited
      #last unless $!main.gtk-main-level();
    }

    # End the main loop
    $!main.gtk-main-quit() if $!main.gtk-main-level();
#    while gtk_events_pending() { gtk_main_iteration_do(False); }
  }

  note "    Done testing";

  return ~($!steps.elems // 0);
}
