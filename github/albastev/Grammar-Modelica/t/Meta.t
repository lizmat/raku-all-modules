#!perl6

use v6;
use lib 'lib';

use Test;
plan 1;

constant AUTHOR = $%*ENV<AUTHOR_TESTING>;

if AUTHOR {
require Test::META <&meta-ok>;

# That's it
meta-ok();


done-testing;
}
else {
  skip-rest "Skipping META6.json test that breaks on AppVeyor";
  exit;
}
