use v6;

use Panda::Common;
use Panda::Builder;
use LibraryCheck;

class Build is Panda::Builder {
    method build($workdir) {
        if !library-exists('samplerate', v0) {
            say "Won't build because no libsamplerate";
            die "You need to have libsamplerate installed";
        }
        True;
    }
}
