use v6;
use Test;

use Test::META;

constant AUTHOR = ?%*ENV<TEST_AUTHOR>; 

if AUTHOR { 
    meta-ok :relaxed-name;
    done-testing;
}
else {
    #skip-rest "Skipping author test";
    say "Skipping author test";
    done-testing;
    exit;
}
