use v6;
use NativeCall;

use GTK::V3::N::NativeLib;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkmain.h
unit class GTK::V3::Gtk::GtkMain:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_events_pending ( )
    returns Bool
    is native(&gtk-lib)
    { * }

sub gtk_init ( CArray[int32] $argc, CArray[CArray[Str]] $argv )
    is native(&gtk-lib)
    { * }

sub gtk_init_check ( CArray[int32] $argc, CArray[CArray[Str]] $argv )
    returns int32
    is native(&gtk-lib)
    { * }

sub gtk_main ( )
    is native(&gtk-lib)
    { * }

sub gtk_main_iteration ( )
    is native(&gtk-lib)
    { * }

sub gtk_main_iteration_do ( Bool $blocking )
    returns Bool
    is native(&gtk-lib)
    { * }

sub gtk_main_level ( )
    returns uint32
    is native(&gtk-lib)
    { * }

sub gtk_main_quit ( )
    is native(&gtk-lib)
    { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( Bool :$check = False ) {

  # Must setup gtk otherwise perl6 will crash
  my $argc = CArray[int32].new;
  $argc[0] = 1 + +@*ARGS;

  my $arg_arr = CArray[Str].new;
  my Int $arg-count = 0;
  $arg_arr[$arg-count] = $*PROGRAM.Str;
  for @*ARGS -> $arg {
    $arg_arr[$arg-count] = $arg;
  }

  my $argv = CArray[CArray[Str]].new;
  $argv[0] = $arg_arr;

  # here, we don't need fancy calling with self.gtk-init( $argc, $argv);
  if $check {
    gtk_init_check( $argc, $argv);
  }

  else {
    gtk_init( $argc, $argv);
  }
}

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, |c ) {

  CATCH {
    when X::AdHoc {
      die X::Gui.new(:message(.message));
    }

    when X::TypeCheck::Argument {
      die X::Gui.new(:message(.message));
    }

    default {
      .rethrow;
      #die X::GUI.new(
      #  :message("Could not find native sub '$native-sub\(...\)'")
      #);
    }
  }

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');

  my Callable $s;
  try { $s = &::($native-sub); }

#note "l call sub: ", $s.perl, ', ', $!gtk-widget.perl;
  &$s(|c)
}
