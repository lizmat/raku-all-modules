use Test;
use lib 'lib';
use Terminal::WCWidth;

sub assert-length($str, @each, $phrase, $msg = "wcwidth test") {
  my @actual-each = $str.NFC.map(&wcwidth);
  my $actual-phrase = wcswidth($str);
  is @actual-each, @each,
    "$msg: $str expects @each[] and gets @actual-each[]";
  is $actual-phrase, $phrase,
    "$msg: $str expects $phrase and gets $actual-phrase";
}

assert-length("コンニチハ, セカイ!",
  (2, 2, 2, 2, 2, 1, 1, 2, 2, 2, 1),
  19,
  "Width of Japanese phrase: コンニチハ, セカイ!"
);
assert-length("abc\0def",
  (1, 1, 1, 0, 1, 1, 1),
  6,
  "NULL (0) should report width 0."
);
assert-length("\x1b[0m",
  (-1, 1, 1, 1),
  -1,
  "CSI should report width -1."
);
assert-length("--\x05bf--",
  (1, 1, 0, 1, 1),
  4,
  "Simple combining character test."
);
# café test not done since Perl6 will inevitably mess it up
assert-length("\x0410\x0488",
  (1, 0),
  1,
  "CYRILLIC CAPITAL LETTER A + COMBINING CYRILLIC " ~
    "HUNDRED THOUSANDS SIGN is А҈ of length 1."
);
assert-length("\x1B13\x1B28\x1B2E\x1B44",
  (1, 1, 1, 1),
  4,
  "Balinese kapal (ship) is ᬓᬨᬮ᭄ of length 4."
);

done-testing;
