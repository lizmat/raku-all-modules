use Panda::Common;
use Panda::Builder;
use Shell::Command;
use LibraryMake;

class Build is Panda::Builder {
    method build($workdir) {
	mkpath $workdir~'/resources';
        make("$workdir/src", "$workdir/resources");
    }
}
