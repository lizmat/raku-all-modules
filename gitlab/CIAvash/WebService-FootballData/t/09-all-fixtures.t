use v6;
use Test;
use WebService::FootballData::Fixtures::AllFixtures;
use WebService::FootballData::Role::HasFixtures;

plan 1;

my $obj = WebService::FootballData::Fixtures::AllFixtures.new;
does-ok $obj, WebService::FootballData::Role::HasFixtures;
