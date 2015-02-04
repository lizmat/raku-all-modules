use Test;
plan *;

use Text::Fortune;
let $*CWD = 't/test_data';

my Buf $b = do { my $f = 'empty.dat'.IO.open; $f.read($f.s) };
say $b;

given Text::Fortune::Index.new {
  is .version, 2, 'is version: 2';
  is .Buf, $b, 'matches empty.dat';
}

given Text::Fortune::Index.new(:rotated, delimiter => '@') {
  is .flags-to-int, 4, 'flags might work';
  is .delimiter, '@', 'can set delimiter';
  is .rotated, True, 'is rotated';
}

done;

# vim: ft=perl6
