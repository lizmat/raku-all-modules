use v6.c;
use NativeCall;
use Net::LibIDN::Native;
unit module Net::LibIDN::Free;

sub idn_free(Pointer) is native(LIB) is export { * }
