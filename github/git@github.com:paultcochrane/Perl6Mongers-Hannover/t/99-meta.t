use v6;
use lib 'lib';
use Test;
plan 1;

if ?%*ENV<AUTHOR_TESTING> {
    require Test::META <&meta-ok>;
    meta-ok;
    done-testing;
}
else {
     skip-rest "Skipping author test";
     exit;
}

# vim: expandtab shiftwidth=4 softtabstop=4 ft=perl6
