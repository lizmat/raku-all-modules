use Test;
plan *;

use Text::Fortune;
let $*CWD = 't/test_data';

my Buf $b = do { my $f = 'with_dat.dat'.IO; my $s = $f.s; $f.open(:bin).read($s); };

given Text::Fortune::Index.new.load-dat( 'with_dat.dat' ) {
  is .offset-at(0), 0, 'first offset correct';
  is .offset-at(2), 9, 'last offset correct';
  is .offset-at(3), 17, 'final offset correct';
  is .bytelength-of(0), 2, 'first length correct';
  is .bytelength-of(2), 6, 'last length correct';
  throws-like { .bytelength-of(3) },
    X::Index::OutOfBounds;
  is .Buf, $b, 'serializes correctly';
}

done-testing;

# vim: ft=perl6
