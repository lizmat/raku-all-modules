use v6;
use NativeCall;

use GTK::Glade::NativeLib;

#-------------------------------------------------------------------------------
unit module GTK::Glade::Native::Gtk:auth<github:MARTIMM>;

#TODO dunno where to place it yet
class GError is repr('CStruct') is export {
  #has GQuark $.domain;
  has uint32 $.domain;
  has int32 $.code;
  has CArray[int8] $.message;
}

#class GObject is repr('CPointer') is export { }
