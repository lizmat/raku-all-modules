use v6;
use LibraryMake;

class Build {
    method build($workdir) {
        my $destdir = $workdir.IO.add('resources/lib').Str;
        my %vars = get-vars($destdir);
        my $libname = 'libnumpack';
        process-makefile('.', %vars);
        mkdir $destdir;
        run 'make';
        spurt($destdir.IO.add($libname) ~ '.so', 'placeholder') if %vars<SO> ne '.so';
        spurt($destdir.IO.add($libname) ~ '.dll', 'placeholder') if %vars<SO> ne '.dll';
        spurt($destdir.IO.add($libname) ~ '.dylib', 'placeholder') if %vars<SO> ne '.dylib';
    }

    # Only needed for panda compatability
    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
