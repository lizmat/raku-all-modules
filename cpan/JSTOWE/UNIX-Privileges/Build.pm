use v6;

use Shell::Command;
use LibraryMake;

class Build  {
    method build($workdir) {
        my $srcdir = $workdir.IO.add('src').Str;
        my Str $destdir = "$workdir/lib/../resources/libraries";
        mkpath $destdir;
        my %vars = get-vars($destdir);
        %vars<unix_privileges> = $*VM.platform-library-name('unix_privileges'.IO).Str;
        process-makefile($srcdir, %vars);
        my $goback = $*CWD;
        chdir($srcdir);
        shell(%vars<MAKE>);
        chdir($goback);

    }
    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
