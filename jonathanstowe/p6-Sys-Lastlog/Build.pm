#!perl6

use v6;

use Panda::Common;
use Panda::Builder;
use LibraryMake;
use Shell::Command;

class Build is Panda::Builder {
    method build($workdir) {
        if $*DISTRO.is-win {
            die "Sys::Lastlog will not work on Windows - sorry";
        }
        given $*KERNEL.name {
            when 'darwin' {
                die "This currently does not work on darwin";
            }
        }
        my Str $destdir = "$workdir/lib/../resources/lib";
        mkpath $destdir;
        make("$workdir/src", "$destdir");
    }
}
# vim: expandtab shiftwidth=4 ft=perl6 ts=4 sts=4
