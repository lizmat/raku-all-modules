use v6;
use Panda::Builder;

class Build is Panda::Builder {
    method build ($where) {
        require($?FILE.IO.parent.child('gen-libs.p6'));
    }
}

# vim: set expandtab:ft=perl6:ts=4:sw=4
