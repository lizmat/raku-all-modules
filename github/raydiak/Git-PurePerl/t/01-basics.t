use v6;

use Test;
plan 2;

use Git::PurePerl;

ok 1, 'Module loads successfully';
isa-ok my $g = Git::PurePerl.new(:directory<.>), Git::PurePerl, '.new works';

done-testing;

# vim: ft=perl6
