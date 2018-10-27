use v6.c;

use LibraryCheck;

class Build {
    method build($workdir) {
        if !library-exists('shout', v3) {
            say "Won't build because no libshout (API v3)";
            die "You need to have libshout installed";
        }
        True;
    }
    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
