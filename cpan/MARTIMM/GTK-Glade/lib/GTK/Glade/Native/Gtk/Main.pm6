use v6;
use NativeCall;

use GTK::Glade::NativeLib;
#use GTK::Glade::Native::Gtk;
#use GTK::Glade::Native::Gtk::Widget;

#-------------------------------------------------------------------------------
# See /usr/include/gtk-3.0/gtk/gtkmain.h
unit module GTK::Glade::Native::Gtk::Main:auth<github:MARTIMM>;

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
