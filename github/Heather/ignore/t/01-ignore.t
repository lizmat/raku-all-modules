use v6;
use Test;

plan 3;

my $f = '.gitignore';
my $i = 'Makefile';

unlink $f if $f.IO.e;
nok $f.IO.e;

# make sure file exists before we try to ignore it
"Makefile".IO.spurt('test');

run (<perl6 bin/ignore --git>, $i);
ok $f.IO.e;

unlink("Makefile");

given open $f, :r {
  ok .lines[0] eq "/$i";
  .close
}
