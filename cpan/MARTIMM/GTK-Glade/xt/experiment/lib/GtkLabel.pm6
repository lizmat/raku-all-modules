use v6;
use NativeCall;

use N::NativeLib;
use GtkWidget;

#-------------------------------------------------------------------------------
unit class GtkLabel does GtkWidget;

#-------------------------------------------------------------------------------
sub gtk_label_new ( Str $text )
  returns N-GtkWidget
  is native(&gtk-lib)
  is export
  { * }

#-------------------------------------------------------------------------------
sub gtk_label_get_text ( N-GtkWidget $label )
  returns Str
  is native(&gtk-lib)
  is export
  { * }

# = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
submethod BUILD ( Str:D :$text, Bool :$visible = True ) {

  $!gtk-widget = gtk_label_new($text);
  #gtk_widget_set_visible( $!gtk-widget, $visible);
  self.set_visible($visible);
}

#-------------------------------------------------------------------------------
method FALLBACK ( $native-sub is copy, |c ) {

  $native-sub ~~ s:g/ '-' /_/;

  my &s;
#note "l s0: $native-sub, ", &s;
  try { &s = &::($native-sub); }
#note "l s1: gtk_label_$native-sub, ", &s unless ?&s;
  try { &s = &::('gtk_label_' ~ $native-sub); } unless ?&s;
#note "l s2: gtk_widget_$native-sub, ", &s unless ?&s;
  try { &s = &::('gtk_widget_' ~ $native-sub); } unless ?&s;

  CATCH {
    default {
      note "Cannot call $native-sub. Sub is not found";
      note .message;
    }
  }

  &s( $!gtk-widget, |c)
}

#-------------------------------------------------------------------------------
#method get-text ( --> Str ) {
#  #gtk_label_get_text($!gtk-widget)
#  self.gtk_label_get_text()
#}
