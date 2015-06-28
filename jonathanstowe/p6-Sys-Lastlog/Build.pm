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
        mkpath "$workdir/blib/lib";
        make("$workdir/src", "$workdir/blib/lib");
    }
}
