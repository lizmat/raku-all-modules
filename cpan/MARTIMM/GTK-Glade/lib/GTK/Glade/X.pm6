use v6;

#-------------------------------------------------------------------------------
class X::GTK::Glade is Exception {
  has $.message;

  submethod BUILD ( Str:D :$!message ) { }
}
