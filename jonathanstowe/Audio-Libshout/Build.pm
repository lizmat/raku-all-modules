use v6;

use Panda::Common;
use Panda::Builder;
use LibraryCheck;

class Build is Panda::Builder {
    method build($workdir) {
        if !library-exists('libshout') {
            say "Won't build because no libshout";
            die "You need to have libshout installed";
        }
        True;
    }
}
