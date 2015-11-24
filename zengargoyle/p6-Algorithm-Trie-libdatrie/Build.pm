# vim: ft=perl6

use Panda::Common;
use Panda::Builder;
use LibraryCheck;
use LibraryMake;
use Shell::Command;

class Build is Panda::Builder {
  method build($workdir) {
    if !library-exists('libdatrie') {
      note "Building libdatrie";
      mkpath "$workdir/blib/lib";
      make "$workdir/src", "$workdir/blib/lib";
    }
  }
}
