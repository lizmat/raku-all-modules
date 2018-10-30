use v6.c;

class Build {
    method build($workdir) {
        if $*DISTRO.is-win {
            die "Crypt::Libcrypt is not supported on Windows";
        }
        True;
    }
    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
