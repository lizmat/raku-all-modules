use v6;
use LibraryMake;

class Build {
    method build($dist-path) {
        if !$*DISTRO.is-win {
            my Str $ext = "$dist-path/ext/crypt_blowfish-1.3";
            my Str $res = "$dist-path/resources";
            mkdir($res);
            unlink("$ext/crypt_blowfish.so");
            unlink("$ext/crypt_blowfish.o", "$ext/crypt_gensalt.o");
            unlink("$ext/wrapper.o", "$ext/x86.o");
            make($dist-path, "$res");
        }
    }

    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}

# vim: ft=perl6
