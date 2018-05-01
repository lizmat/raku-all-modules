use Shell::Command;
use LibraryMake;

class Build {
    method build($workdir) {
        mkpath $workdir~'/resources';
        make("$workdir/src", "$workdir/resources");
    }
}
