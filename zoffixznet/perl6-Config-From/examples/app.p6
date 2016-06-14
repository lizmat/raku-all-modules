use lib 'lib';
use Config::From 'examples/config.json';

my $user   is from-config;
my $pass   is from-config;
my @groups is from-config;
say "$user\'s password is $pass and they belong to @groups[]";
