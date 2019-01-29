use v6;
use NativeCall;

use N::NativeLib;
use GUI;
use GtkWidget;

#-------------------------------------------------------------------------------
unit class GtkLabel:auth<github:MARTIMM> is GtkWidget does GUI;

#-------------------------------------------------------------------------------
sub gtk_label_new ( Str $text )
  returns N-GtkWidget
  is native(&gtk-lib)
  #  is export
  { * }

#-------------------------------------------------------------------------------
sub gtk_label_get_text ( N-GtkWidget $label )
  returns Str
  is native(&gtk-lib)
  #  is export
  { * }


# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( Str:D :$text ) {

  $!gtk-widget = gtk_label_new($text);
}

#-------------------------------------------------------------------------------
method fallback ( $native-sub is copy --> Callable ) {

  $native-sub ~~ s:g/ '-' /_/ if $native-sub.index('-');

  my Callable $s;
#note "l s0: $native-sub, ", $s;
  try { $s = &::($native-sub); }
#note "l s1: gtk_label_$native-sub, ", $s unless ?$s;
  try { $s = &::("gtk_label_$native-sub"); } unless ?$s;
  $s = callsame unless ?$s;

  CATCH {
    default {
      .note;
    }
  }

#note "l call sub: ", $s.perl, ', ', $!gtk-widget.perl;
  &$s
}
