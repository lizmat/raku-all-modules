use LibraryMake;
use Shell::Command;

class Build {
    method build($workdir) {
        my $makefiledir = "$workdir/src";
        my $destdir = "$workdir/resources";
        mkpath $destdir;
        make($makefiledir, $destdir);

        my $lib = "libmurmurhash3";
        my $so = get-vars('')<SO>;
        my @fake = <.so .dll .dylib>.grep({ $_ ne $so });
        for @fake -> $fake {
            my $file = "{$destdir}/{$lib}{$fake}";
            $file.IO.spurt("fake");
        }
    }
}
