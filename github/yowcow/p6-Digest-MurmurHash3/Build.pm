use v6;
use LibraryMake;

class Build {
    method build($srcdir) {
        my %vars = get-vars($srcdir);

        my $destdir = "$srcdir/resources";
        mkdir $destdir unless $destdir.IO.e;
        %vars<DESTDIR> = $destdir;

        process-makefile($srcdir, %vars);
        shell %vars<MAKE>, :cwd($srcdir);

        # write fake libs
        my $so = get-vars('')<SO>;
        my @fakes = <.so .dll .dylib>.grep({ $_ ne $so });
        for @fakes -> $fake {
            my $file = "{$destdir}/libmurmurhash3{$fake}";
            $file.IO.spurt("fake");
        }

        1; # return true
    }
}
