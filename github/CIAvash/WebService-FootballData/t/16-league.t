use v6;
use Test;
use lib 't/lib';
use FakeRequest;
use WebService::FootballData::League;
use WebService::FootballData::Role::Request;
use WebService::FootballData::Request;

plan 69;

my $obj = WebService::FootballData::League.new: :request(WebService::FootballData::Request.new), links => {};
does-ok $obj, WebService::FootballData::Role::ID;
does-ok $obj, WebService::FootballData::Role::HasRequest;
can-ok $obj, 'name';
isa-ok $obj.name, Str;
can-ok $obj, 'code';
isa-ok $obj.code, Str;
can-ok $obj, 'season';
isa-ok $obj.season, Str;
can-ok $obj, 'current_matchday';
isa-ok $obj.current_matchday, Int;
can-ok $obj, 'number_of_matchdays';
isa-ok $obj.number_of_matchdays, Int;
can-ok $obj, 'number_of_teams';
isa-ok $obj.number_of_teams, Int;
can-ok $obj, 'number_of_games';
isa-ok $obj.number_of_games, Int;
can-ok $obj, 'last_updated';
isa-ok $obj.last_updated, DateTime;
can-ok $obj, 'teams';
can-ok $obj, 'table';
can-ok $obj, 'fixtures';

my $league = WebService::FootballData::League.new(
    request => FakeRequest.new,
    links => {
        self => href => 'soccerseasons/351',
        teams => href => 'soccerseasons/351/teams',
        fixtures => href => 'soccerseasons/351/fixtures',
        leagueTable => href => 'soccerseasons/351/leagueTable',
    },
);

# League.teams
my @teams;
lives-ok { @teams = $league.teams }, 'Get teams of a league';
isa-ok @teams[0], WebService::FootballData::Team;
is @teams[0].name, 'FC Bayern München', 'Has the correct name';

# League.table
my $table;
lives-ok { $table = $league.table }, 'Get league table';
isa-ok $table, WebService::FootballData::League::Table;
is $table.name, '1. Bundesliga 2014/15', 'Has the correct name';
is $table.matchday, 34, 'Has the correct matchday';

# League.table.rows
my @table_rows;
lives-ok { @table_rows = $table.rows }, 'Get table rows for a league';
is @table_rows[1].id, 11, 'Has the correct id';
is @table_rows[1].name, 'VfL Wolfsburg', 'Has the correct name';
is @table_rows[1].crest_url, 'https://upload.wikimedia.org/wikipedia/commons/f/f3/Logo-VfL-Wolfsburg.svg', 'Has the correct crest_url';
is @table_rows[1].position, 2, 'Has the correct position';
is @table_rows[1].games_played, 34, 'Has the correct games_played';
is @table_rows[1].goals_for, 72, 'Has the correct goals_for';
is @table_rows[1].goals_against, 38, 'Has the correct goals_against';
is @table_rows[1].goal_difference, 34, 'Has the correct goal_difference';
is @table_rows[1].wins, 20, 'Has the correct wins';
is @table_rows[1].draws, 9, 'Has the correct draws';
is @table_rows[1].losses, 5, 'Has the correct losses';
is @table_rows[1].home.goals_for, 38, 'Has the correct home goals_for';
is @table_rows[1].home.goals_against, 13, 'Has the correct home goals_against';
is @table_rows[1].home.wins, 13, 'Has the correct home wins';
is @table_rows[1].home.draws, 4, 'Has the correct home draws';
is @table_rows[1].home.losses, 0, 'Has the correct home losses';
is @table_rows[1].away.goals_for, 34, 'Has the correct away goals_for';
is @table_rows[1].away.goals_against, 25, 'Has the correct away goals_against';
is @table_rows[1].away.wins, 7, 'Has the correct away wins';
is @table_rows[1].away.draws, 5, 'Has the correct away draws';
is @table_rows[1].away.losses, 5, 'Has the correct away losses';
is @table_rows[1].points, 69, 'Has the correct points';

my $table_day5;
lives-ok { $table_day5 = $league.table(5) }, 'Get league table of matchday 5';
isa-ok $table_day5, WebService::FootballData::League::Table;
is $table_day5.name, '1. Bundesliga 2014/15', 'Has the correct name';
is $table_day5.matchday, 5, 'Has the correct matchday';

my @day5_rows;
lives-ok { @day5_rows = $table_day5.rows }, 'Get table rows of matchday 5 for a league';
is @day5_rows[1].name, 'Bayer Leverkusen', 'Has the correct name';

# League.fixtures
my @fixtures;
lives-ok { @fixtures = $league.fixtures }, 'Get fixtures of a league';
isa-ok @fixtures[0], WebService::FootballData::Fixtures::Fixture;
is @fixtures[0].matchday, 1, 'Has the correct matchday';
is @fixtures[0].home_team_name, 'FC Bayern München', 'Has the correct home_team_name';

my @fixtures_m10;
lives-ok { @fixtures_m10 = $league.fixtures: :matchday(10) }, 'Get fixtures of a league, filtered by matchday';
isa-ok @fixtures_m10[0], WebService::FootballData::Fixtures::Fixture;
is @fixtures_m10[0].matchday, 10, 'Has the correct matchday';
is @fixtures_m10[0].away_team_name, 'Borussia Dortmund', 'Has the correct away_team_name';

my @fixtures_p80;
lives-ok { @fixtures_p80 = $league.fixtures: :timeframe<p80> }, 'Get fixtures of a league, filtered by timeframe';
isa-ok @fixtures_p80[0], WebService::FootballData::Fixtures::Fixture;
is @fixtures_p80[0].matchday, 33, 'Has the correct matchday';
is @fixtures_p80[0].home_team_name, 'VfL Wolfsburg', 'Has the correct home_team_name';