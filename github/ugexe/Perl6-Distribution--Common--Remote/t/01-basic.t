use Test;
plan 2;

use Distribution::Common::Remote::Github;

my $dist = Distribution::Common::Remote::Github.new(:user("ugexe"), :repo("Perl6-Distribution--Common"), :branch("master"));
is $dist.meta<provides><Distribution::Common>, 'lib/Distribution/Common.pm6';
ok $dist.content('lib/Distribution/Common.pm6').open.slurp-rest.contains('role Distribution::Common');
