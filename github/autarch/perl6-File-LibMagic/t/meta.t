use v6;
use lib 'lib';
use Test;

constant AUTHOR = ?%*ENV<AUTHOR_TESTING>;

if AUTHOR {
    require Test::META <&meta-ok>;
    meta-ok;
    done-testing;
}
else {
    ok( 1, 'this test is only run when the AUTHOR_TESTING env var is true' );
    done-testing;
}
