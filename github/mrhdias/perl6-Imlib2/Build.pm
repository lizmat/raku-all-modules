use Panda::Common;
use Panda::Builder;
use LibraryMake;

class Build is Panda::Builder {
    method build($workdir) {
        shell("mkdir -p $workdir/blib/lib");
        make("$workdir/src", "$workdir/blib/lib");
    }
}
