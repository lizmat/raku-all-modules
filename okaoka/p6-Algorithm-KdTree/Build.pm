use Panda::Common;
use Panda::Builder;
use LibraryMake;
use Shell::Command;

class Build is Panda::Builder {
    method build($workdir) {
	my $makefiledir = "$workdir/src";
	my $destdir = "$workdir/resources";
	mkpath $destdir unless $destdir.IO.d;
	make($makefiledir, $destdir);
	my $lib = "libkdtree";
	my $so = get-vars('')<SO>;
	my @fake = <.so .dll .dylib>.grep({$_ ne $so});
	for @fake -> $fake {
	    my $file = "$destdir/$lib$fake";
	    $file.IO.spurt("fake\n");
	}
    }
}
