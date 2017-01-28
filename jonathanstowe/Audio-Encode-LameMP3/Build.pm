use v6.c;

use LibraryCheck;

class Build {
    method build($workdir) {
        if !library-exists('mp3lame', v0) {
            say "Won't build because no libmp3lame";
            die "You need to have libmp3lame installed";
        }
        True;
    }
    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
