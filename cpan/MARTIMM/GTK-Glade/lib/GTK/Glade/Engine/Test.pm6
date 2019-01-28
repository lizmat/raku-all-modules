use v6;

use NativeCall;
use GTK::Glade::NativeGtk :ALL;
use GTK::Glade::Native::Gtk;
use GTK::Glade::Native::Glib::GSignal;
use GTK::Glade::Native::Gtk::Main;
use GTK::Glade::Native::Gtk::Widget;
use GTK::Glade::Native::Gtk::Builder;
use GTK::Glade::Engine;
#use GTK::Glade::Gdkkeysyms;

#-------------------------------------------------------------------------------
unit role GTK::Glade::Engine::Test:auth<github:MARTIMM> is GTK::Glade::Engine;

# Must be set before by GTK::Glade::Engine::Work.glade-run().
has $.builder is rw;


has GtkWidget $!widget;
has Str $!text;


#-----------------------------------------------------------------------------
# This method runs in a thread from where no gui updates may take place
# https://stackoverflow.com/questions/30607429/gtk3-and-multithreading-replacing-deprecated-functions
method run-tests (
  GTK::Glade::Engine::Test:D $test-setup,
#  Str:D $toplevel-id
  --> Str
) {

  my Int $executed-tests = 0;

  if ?$test-setup and ?$test-setup.steps and $test-setup.steps ~~ Array {
    $!widget = GtkWidget;
    $!text = Str;

    for $test-setup.steps -> Pair $substep {
      note "    Substep: $substep.key() => ",
            $substep.value() ~~ Block ?? 'Code block' !! $substep.value();

      given $substep.key {

        when 'set-widget' {
          $!widget = gtk_builder_get_object( $!builder, $substep.value);
        }

        when 'emit-signal' {
          next unless ?$!widget;
          my $result;
          g_signal_emit_by_name(
            $!widget, $substep.value, $!widget, "x", $result
          );
        }

        when 'get-text' {
          if ?$!widget and gtk_widget_get_has_window($!widget) {

            my $buffer = gtk_text_view_get_buffer($!widget);
            $!text = gtk_text_buffer_get_text(
              $buffer, self.glade-start-iter($buffer),
              self.glade-end-iter($buffer), 1
            )
          }
        }

        when 'set-text' {
          if ?$!widget and gtk_widget_get_has_window($!widget) {

            my $buffer = gtk_text_view_get_buffer($!widget);
            #gtk_text_buffer_set_text( $buffer, $substep.value, -1);
            gtk_text_buffer_set_text( $buffer, $substep.value, -1);
          }
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
      while gtk_events_pending() { gtk_main_iteration_do(False); }
#note "LL 1b: ", gtk_main_level();

      # Stop when loop is exited
      last unless gtk_main_level();
    }

    # End the main loop
    gtk_main_quit() if gtk_main_level();
    while gtk_events_pending() { gtk_main_iteration_do(False); }
  }

  note "    Done testing";

  return ~(+($test-setup.steps) // 0);
}
