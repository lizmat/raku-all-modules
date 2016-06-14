use v6;
use Test;
use WebService::FootballData::Fixtures::Fixture;
use WebService::FootballData::Fixtures::Fixture::Result;
use WebService::FootballData::Role::ID;

plan 19;

my $obj = WebService::FootballData::Fixtures::Fixture.new: links => {};
does-ok $obj, WebService::FootballData::Role::ID;
can-ok $obj, 'date';
isa-ok $obj.date, DateTime;
can-ok $obj, 'status';
isa-ok $obj.status, Str;
can-ok $obj, 'matchday';
isa-ok $obj.matchday, Int;
can-ok $obj, 'home_team_name';
isa-ok $obj.home_team_name, Str;
can-ok $obj, 'away_team_name';
isa-ok $obj.away_team_name, Str;
can-ok $obj, 'result';
isa-ok $obj.result, WebService::FootballData::Fixtures::Fixture::Result;
can-ok $obj, 'league_id';
can-ok $obj, 'home_team_id';
can-ok $obj, 'away_team_id';

my $fixture = WebService::FootballData::Fixtures::Fixture.new(
    links => {
        soccerseason => href => 'some/url/123',
        homeTeam => href => 'some/url/456',
        awayTeam => href => 'some/url/789',
    }
);

is $fixture.league_id, 123, 'Has the correct league_id';
is $fixture.home_team_id, 456, 'Has the correct home_team_id';
is $fixture.away_team_id, 789, 'Has the correct away_team_id';