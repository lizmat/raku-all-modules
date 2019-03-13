use v6;
use Test;
use NativeCall;

use GTK::Glade::Engine;

use GTK::V3::Glib::GObject;
use GTK::V3::Glib::GMain;
use GTK::V3::Gtk::GtkButton;
use GTK::V3::Gtk::GtkMain;
use GTK::V3::Gtk::GtkBuilder;
use GTK::V3::Gtk::GtkTextIter;

#-------------------------------------------------------------------------------
unit role GTK::Glade::Engine::Test:auth<github:MARTIMM>;
also is GTK::Glade::Engine;

# Must be set before by GTK::Glade::Engine::Work.glade-run().
has GTK::V3::Gtk::GtkBuilder $.builder is rw;

has GTK::V3::Gtk::GtkMain $!main;
#has GTK::V3::Glib::GObject $!widget;
has Any $!test-value;
has Array $.steps;

#-------------------------------------------------------------------------------
# This method runs in a thread. Gui updates can be done using a context
method prepare-and-run-tests ( ) {

  # run tests in a thread
  my Promise $p = start {
    # wait for loop to start
    sleep(1.1);
    my $result;

    my GTK::V3::Glib::GMain $gmain .= new;
    my $main-context = $gmain.context-get-thread-default;

    $gmain.context-invoke(
      $main-context,
      -> $d {
        $result = self!run-tests;
        0
      },
      OpaquePointer
    );

    $result
  }

  # the main loop on the main thread
  $!main.gtk_main();

  # wait for the end and show result
  await $p;
  diag $p.result;
}

#-------------------------------------------------------------------------------
method !run-tests ( ) {

  my Int $executed-tests = 0;

  if $!steps.elems {

    my Bool $ignore-wait = False;
    my $step-wait = 0.0;

    for @$!steps -> Pair $substep {
      if $substep.value() ~~ Block {
        diag "substep: $substep.key() => Code block";
      }

      elsif $substep.value() ~~ List {
        diag "substep: $substep.key() => ";
        for @($substep.value()) -> $v {
          diag "           $v.key() => $v.value()";
        }
      }

      else {
        diag "substep: $substep.key() => $substep.value()";
      }

      given $substep.key {
        when 'emit-signal' {
          my Hash $ss = %(|$substep.value);
          my Str $signal-name = $ss<signal-name> // 'clicked';
          my $widget = self!get-widget($ss);
          $widget.emit-by-name-wd( $signal-name, $widget, OpaquePointer);
        }

        when 'get-text' {
          my Hash $ss = %(|$substep.value);
          my $widget = self!get-widget($ss);
          my GTK::V3::Gtk::GtkTextBuffer $buffer .= new(
            :widget($widget.get-buffer)
          );

          my GTK::V3::Gtk::GtkTextIter $start .= new;
          $buffer.get-start-iter($start);
          my GTK::V3::Gtk::GtkTextIter $end .= new;
          $buffer.get-end-iter($end);

          $!test-value = $buffer.get-text( $start, $end, 1);
        }

        when 'set-text' {
          my Hash $ss = %(|$substep.value);
          my Str $text = $ss<text>;
          my $widget = self!get-widget($ss);

          my $n-buffer = $widget.get-buffer;
          my GTK::V3::Gtk::GtkTextBuffer $buffer .= new(:widget($n-buffer));
          $buffer.set-text( $text, $text.chars);
          $widget.queue-draw;
        }

        when 'do-test' {
          next unless $substep.value ~~ Block;
          $executed-tests++;
          $substep.value()();
        }

        when 'get-main-level' {
          $!test-value = $!main.gtk-main-level;
        }

        when 'step-wait' {
          $step-wait = $substep.value();
        }

        when 'ignore-wait' {
          $ignore-wait = ?$substep.value();
        }

        when 'wait' {
          sleep $substep.value() unless $ignore-wait;
        }

        when 'debug' {
          GTK::V3::Gtk::GtkButton.new(:empty).debug(:on($substep.value()));
        }

        when 'finish' {
          last;
        }
      }

      sleep($step-wait)
        unless ( $substep.key eq 'wait' or $ignore-wait or $step-wait == 0.0 );

      # make sure things get displayed
      while $!main.gtk-events-pending() { $!main.iteration-do(False); }

      # Stop when loop is exited
      #last unless $!main.gtk-main-level();
    }

    # End the main loop
    $!main.gtk-main-quit() if $!main.gtk-main-level();
    while $!main.gtk-events-pending() { $!main.iteration-do(False); }
  }

  diag "Done testing";

  return "Nbr steps: {$!steps.elems // 0}, Nbr tests: $executed-tests";
}

#-------------------------------------------------------------------------------
method !get-widget ( Hash $opts --> Any ) {
  my Str:D $id = $opts<widget-id>;
  my Str:D $class = $opts<widget-class>;

  require ::($class);
  my $widget = ::($class).new(:build-id($id));
  is $widget.^name, $class, "Id '$id' of class $class found and initialized";

  $widget
}
