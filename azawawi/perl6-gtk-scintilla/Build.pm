
use v6;

use Panda::Common;
use Panda::Builder;


class Build is Panda::Builder {
    method build($workdir) {
        my $makefiledir = "$workdir/src";
        my $destdir = "$workdir/resources";
        $destdir.IO.mkdir;

        shell("cd $makefiledir && make");
    }
}
