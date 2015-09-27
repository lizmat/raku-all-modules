use v6;
use Panda::Common;
use Panda::Builder;
use LibraryMake;
use Shell::Command;

class Build is Panda::Builder {
    method build($workdir) {
        mkpath "$workdir/blib/lib/Raw/Socket/";
        %*ENV{'LIBS'} ~= ' -lws2_32' if $*DISTRO.is-win;
        make("$workdir", "$workdir/blib/lib/Raw/Socket/");
    }
}
