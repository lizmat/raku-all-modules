use v6.c;
use Test;

subtest {

  say 'Resolve: ', '.'.IO.resolve.Str;
  say 'Abspath: ', '.'.IO.absolute;
  say 'Volume1: ', '.'.IO.volume;
  say 'Volume2: ', '.'.IO.resolve.volume;

  my $l = '.'.IO.resolve.Str;
  $l ~~ s/^ \\ (<[CDE]> ':') /$0/;
  say "Substitution: $l";
  say "Test dir: ", $l.IO ~~ :d;
  say "Test read: ", $l.IO ~~ :r;

  ok 1 == 1, 'always ok';
}, 'windows path tests';

done-testing;
