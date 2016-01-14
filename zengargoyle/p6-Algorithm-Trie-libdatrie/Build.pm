# vim: ft=perl6

use Panda::Common;
use Panda::Builder;
use LibraryMake;
use Shell::Command;

class Build is Panda::Builder {
  method build($workdir) {
    note "Building libdatrie";
    my Str $destdir = "$workdir/lib/../resources/lib";
    mkpath $destdir;
    make "$workdir/src", "$destdir";
  }
}
