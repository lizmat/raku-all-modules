use v6;

#-------------------------------------------------------------------------------
class X::Gui is Exception {
  has $.message;

  submethod BUILD ( Str:D :$!message ) { }
}

#-------------------------------------------------------------------------------
class X::Glade is Exception {
  has $.message;

  submethod BUILD ( Str:D :$!message ) { }
}
