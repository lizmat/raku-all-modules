use v6;
use Shell::Command;
use NativeCall;

# test sub for system library
our sub zlibVersion() returns Str is encoded('ascii') is native('zlib1.dll') is export { * }

class Build {
    method build($workdir) {
        say 'Found system zlib library.';
    }

    method isa($what) {
      return True if $what.^name eq 'Panda::Builder';
      callsame;
    }
}
