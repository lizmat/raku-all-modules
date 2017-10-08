use Test;
plan *;
pass 'bogus';

use Text::Fortune;
let $*CWD = 't/test_data';

my Buf $b = do { my $f = 'with_dat.dat'.IO; my $s = $f.s; $f.open(:bin).read($s); };
my Buf $be = do { my $f = 'empty.dat'.IO; my $s = $f.s; $f.open(:bin).read($s); };

given Text::Fortune::Index.new.load-fortune( 'with_dat' ) {
  say $b;
  say .Buf;
  #is .Buf, $b, 'serializes correctly';
}

given Text::Fortune::Index.new.load-fortune( 'empty' ) {
  say $be;
  say .Buf;
  #is .Buf, $be, 'serializes correctly';
}

done-testing;

# vim: ft=perl6
