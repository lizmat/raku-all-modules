use v6;
use Test;
use WebService::FootballData::Fixtures::Fixture::Result;

plan 4;

my $obj = WebService::FootballData::Fixtures::Fixture::Result.new;
can-ok $obj, 'home_team_goals';
isa-ok $obj.home_team_goals, Int;
can-ok $obj, 'away_team_goals';
isa-ok $obj.away_team_goals, Int;