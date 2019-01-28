use v6;
use NativeCall;

use N::NativeLib;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkmain.h
unit class GtkMain:auth<github:MARTIMM>;

#-------------------------------------------------------------------------------
sub gtk_init ( CArray[int32] $argc, CArray[CArray[Str]] $argv )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_init_check ( CArray[int32] $argc, CArray[CArray[Str]] $argv )
    returns int32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_main ( )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_main_quit ( )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_main_iteration ( )
    is native(&gtk-lib)
    is export
    { * }

sub gtk_main_iteration_do ( Bool $blocking )
    returns Bool
    is native(&gtk-lib)
    is export
    { * }

sub gtk_main_level ( )
    returns uint32
    is native(&gtk-lib)
    is export
    { * }

sub gtk_events_pending ( )
    returns Bool
    is native(&gtk-lib)
    is export
    { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( ) {

  # Must setup gtk otherwise perl6 will crash
  my $argc = CArray[int32].new;
  $argc[0] = 1;

  my $argv = CArray[CArray[Str]].new;
  my $arg_arr = CArray[Str].new;
  $arg_arr[0] = $*PROGRAM.Str;
  $argv[0] = $arg_arr;

  gtk_init( $argc, $argv);
}
