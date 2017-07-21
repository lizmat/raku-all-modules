# vim: ft=perl6

use LibraryMake;
use Shell::Command;

class Build {
  method build($workdir) {
    note "Building libdatrie";
    my Str $destdir = "$workdir/lib/../resources/lib";
    mkpath $destdir;
    make "$workdir/src", "$destdir";
  }
}
