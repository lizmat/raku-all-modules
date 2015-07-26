use v6;

use Panda::Common;
use Panda::Builder;
use LibraryCheck;

class Build is Panda::Builder {
    method build($workdir) {
        if !library-exists('libmp3lame') {
            say "Won't build because no libmp3lame";
            die "You need to have libmp3lame installed";
        }
        True;
    }
}
