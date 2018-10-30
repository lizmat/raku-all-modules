use v6;
use LibraryMake;

class Build {
    method build($dist) {
        if !$*DISTRO.is-win {
            my $ext = "$dist/ext/argon2-20160406";
            my $res = "$dist/resources/libraries";

            my %vars = get-vars($ext);

            mkdir("$dist/resources");
            mkdir($res);
            chdir($ext);
            my $make = %vars<MAKE>;
            my $proc = shell("$make libs");

            if $proc.exitcode != 0 {
                die("make failure: "~$proc.exitcode);
            }

            my $so = %vars<SO>;
            move("$ext/libargon2$so", "$res/libargon2$so");
        }
    }

    method isa($what) {
        return True if $what.^name eq 'Panda::Builder';
        callsame;
    }
}
