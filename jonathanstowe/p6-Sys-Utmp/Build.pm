#!perl6

use v6;

use Panda::Common;
use Panda::Builder;
use LibraryMake;
use Shell::Command;

class Build is Panda::Builder {
   method build($workdir) {
         my Str $destdir = "$workdir/lib/../resources/lib";
         mkpath $destdir;
         make("$workdir/src", $destdir);
   }
}
# vim: ft=perl6 expandtab sw=4
