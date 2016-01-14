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
        
         my $srcdir = $workdir.IO.child('src').Str;
         my Str $destdir = "$workdir/lib/../resources/libraries";
         mkpath $destdir;
         my %vars = get-vars($destdir);
         %vars<lastloghelper> = $*VM.platform-library-name('lastloghelper'.IO).Str;
         process-makefile($srcdir, %vars);
         my $goback = $*CWD;
         chdir($srcdir);
         shell(%vars<MAKE>);
         chdir($goback);
    }
}
# vim: expandtab shiftwidth=4 ft=perl6 ts=4 sts=4
