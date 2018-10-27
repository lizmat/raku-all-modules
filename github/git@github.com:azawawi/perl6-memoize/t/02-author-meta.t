
use v6;

use lib 'lib';
use Test;

plan 1;

if ?%*ENV<TEST_AUTHOR> { 
  require Test::META <&meta-ok>;
  meta-ok;
  done-testing;
} else {
  skip-rest "Skipping author test";
  exit;
}
