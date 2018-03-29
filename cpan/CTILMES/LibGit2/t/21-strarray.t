use Test;
use LibGit2;

plan 8;

ok my $array = Git::Strarray.new, 'new';
is $array.elems, 0, 'no strings';
is $array.list, (), 'empty list';

ok $array = Git::Strarray.new(<foo bar>), 'new';
is $array.elems, 2, 'elems';
is $array.list, <foo bar>, 'list';
is $array[0], 'foo', 'index 0';
is $array[1], 'bar', 'index 1';
