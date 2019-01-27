use LibraryMake;

class Build {
    method build($workdir) {
        shell("mkdir -p $workdir/blib/lib");
        make("$workdir/src", "$workdir/blib/lib");
    }
}
