use v6;

use Panda::Common;
use Panda::Builder;
use LibraryCheck;

class Build is Panda::Builder {
    method build($workdir) {
        if !library-exists('libsndfile') {
            say "Won't build because no libsndfile";
            die "You need to have libsndfile installed";
        }
        True;
    }
}
