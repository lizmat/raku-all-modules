use v6.c;
use Shell::Command;
use LibraryMake;

class Build {
	method build($workdir) {
        my Str $srcdir = $workdir.IO.child('ext').Str;
        my Str $destdir = "$workdir/lib/../resources/libraries";
        mkpath $destdir;
        my %vars = get-vars($destdir);
        %vars<fcgi> = $*VM.platform-library-name('fcgi'.IO).Str;
        process-makefile($srcdir, %vars);
		my $here = $*CWD;
		chdir($srcdir);
		if $srcdir.IO.child('fcgi_config.h') !~~ :f {
			shell("./configure");
		}
		shell(%vars<MAKE>);
		chdir($here);
	}
    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
