use lib 'lib';
use Test;
use Config::From 't/test-config.json';

my $scalar is from-config;
my @array  is from-config;
my %hash   is from-config;

is $scalar, 'got the scalar',           'scalar value successfully retrieved';
is-deeply @array, [<got the array>],      'array value successfully retrieved';
is-deeply %hash, %(<got the hash var>), 'hash value successfully retrieved';

done-testing;
