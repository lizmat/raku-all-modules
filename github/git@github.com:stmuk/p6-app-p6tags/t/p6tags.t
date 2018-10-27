use Test;
use lib 'lib';

plan 1;

my $me =  $?FILE.IO.dirname ~ $*SPEC.dir-sep; 

shell("perl6 {$me}../bin/p6tags {$me}Simple.pm") or die;

my $got = slurp 'tags';
my $expected = slurp 't/tags.good';

ok $got eq $expected , "got expected result" and unlink 'tags';

