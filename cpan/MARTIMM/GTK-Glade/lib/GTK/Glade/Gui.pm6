use v6;

use GTK::Glade::X;

# Role to capture tools and other thingies needed by widgets. This
# means that it cannot be used by GtkMain, GdkScreen etc

#-------------------------------------------------------------------------------
class N-GtkWidget
  is repr('CPointer')
  is export
  { }

#-------------------------------------------------------------------------------
role GTK::Glade::Gui:auth<github:MARTIMM> {

  #-----------------------------------------------------------------------------
  has N-GtkWidget $!gtk-widget;
#  has Str $!native-sub-name = '';

  #-----------------------------------------------------------------------------
  method CALL-ME ( N-GtkWidget $widget? --> N-GtkWidget ) {

    if ?$widget {
      #if GdkWindow::GDK_WINDOW_TOPLEVEL
      #$!gtk-widget = N-GtkWidget;
      $!gtk-widget = $widget;
    }

    $!gtk-widget
  }

  #-----------------------------------------------------------------------------
  # Fallback method to find the native subs which then can be called as if it
  # were a method. Each class must provide their own 'fallback' method which,
  # when nothing found, must call the parents fallback with 'callsame'.
  # The subs in some class all start with some prefix which can be left out too
  # provided that the fallback functions must also test with an added prefix.
  # So e.g. a sub 'gtk_label_get_text' defined in class GtlLabel can be called
  # like '$label.gtk_label_get_text()' or '$label.get_text()'. As an extra
  # feature dashes can be used instead of underscores, so '$label.get-text()'
  # works too.
  method FALLBACK ( $native-sub, |c ) {

    CATCH {
note "Error type: ", $_.WHAT;
note "Error message: ", .message;
#.note;
#TODO will never work
      # X::AdHoc
      when .message ~~ m:s/Cannot invoke this object/ {
        die X::Gui.new(
          :message("Could not find native sub '$native-sub\(...\)'")
        );
      }

      # X::AdHoc
      when .message ~~ m:s/Native call expected return type/ {
        die X::Gui.new(
          :message("Wrong return type of native sub '$native-sub\(...\)'")
        );
      }

      # X::AdHoc
      when .message ~~ m:s/will never work with declared signature/ {
        die X::Gui.new(
          :message("Wrong call arguments to native sub '$native-sub\(...\)'")
        );
      }

      when X::TypeCheck::Argument {
        die X::Gui.new(:message(.message));
      }

      default {
        die X::Gui.new(
          :message("Could not find native sub '$native-sub\(...\)'")
        );
      }
    }

    my Callable $s = self.fallback($native-sub);
    &$s( $!gtk-widget, |c)
  }
}
