use v6;

use Panda::Common;
use Panda::Builder;
class Build is Panda::Builder {
    method build($workdir) {
        if $*DISTRO.is-win {
            die "Crypt::Libcrypt is not supported on Windows";
        }
        if $*DISTRO.name eq 'macosx' {
            die "Unable to determine how to get crypt(3) on macosx";
        }
        True;
    }
}
