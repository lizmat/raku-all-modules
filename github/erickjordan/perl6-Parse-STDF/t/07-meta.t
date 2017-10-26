use v6;
use Test;
use Parse::STDF;

plan 1;

constant AUTHOR = ?%*ENV<TEST_AUTHOR>;

if AUTHOR {
  require Test::META <&meta-ok>;
  meta-ok;
  done-testing;
}
else {
  skip-rest "Skiping author test";
}

