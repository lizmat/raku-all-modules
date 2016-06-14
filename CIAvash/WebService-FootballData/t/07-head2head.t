use v6;
use Test;
use WebService::FootballData::Fixtures::Head2Head;
use WebService::FootballData::Fixtures::Fixture;
use WebService::FootballData::Role::HasFixtures;

plan 15;

my $obj = WebService::FootballData::Fixtures::Head2Head.new;
does-ok $obj, WebService::FootballData::Role::HasFixtures;
can-ok $obj, 'home_team_wins';
isa-ok $obj.home_team_wins, Int;
can-ok $obj, 'away_team_wins';
isa-ok $obj.away_team_wins, Int;
can-ok $obj, 'draws';
isa-ok $obj.draws, Int;
can-ok $obj, 'home_team_last_win_home';
isa-ok $obj.home_team_last_win_home, WebService::FootballData::Fixtures::Fixture;
can-ok $obj, 'home_team_last_win';
isa-ok $obj.home_team_last_win, WebService::FootballData::Fixtures::Fixture;
can-ok $obj, 'away_team_last_win_away';
isa-ok $obj.away_team_last_win_away, WebService::FootballData::Fixtures::Fixture;
can-ok $obj, 'away_team_last_win';
isa-ok $obj.away_team_last_win, WebService::FootballData::Fixtures::Fixture;
