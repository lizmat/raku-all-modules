use v6;

use Panda::Common;
use Panda::Builder;
use LibraryCheck;

class Build is Panda::Builder {
    method build($workdir) {
        if !library-exists('shout', v3) {
            say "Won't build because no libshout (API v3)";
            die "You need to have libshout installed";
        }
        True;
    }
}
