use v6;
use Test;

constant AUTHOR = ?%*ENV<TEST_AUTHOR>; 

if AUTHOR { 
    require Test::META <&meta-ok>;
    meta-ok;
    done-testing;
}
else {
    #skip-rest "Skipping author test";
    say "Skipping author test";
    done-testing;
    exit;
}
