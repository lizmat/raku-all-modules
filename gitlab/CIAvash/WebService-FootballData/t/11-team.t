use v6;
use Test;
use lib 't/lib';
use FakeRequest;
use WebService::FootballData::Team;
use WebService::FootballData::Role::ID;
use WebService::FootballData::Request;
use WebService::FootballData::Role::HasRequest;

plan 34;

my $obj = WebService::FootballData::Team.new: :request(WebService::FootballData::Request.new), links => {};
does-ok $obj, WebService::FootballData::Role::ID;
does-ok $obj, WebService::FootballData::Role::HasRequest;
can-ok $obj, 'name';
isa-ok $obj.name, Str;
can-ok $obj, 'short_name';
isa-ok $obj.short_name, Str;
can-ok $obj, 'code';
isa-ok $obj.code, Str;
can-ok $obj, 'squad_market_value';
isa-ok $obj.squad_market_value, Str;
can-ok $obj, 'crest_url';
isa-ok $obj.crest_url, Str;
can-ok $obj, 'players';
can-ok $obj, 'fixtures';

my $team = WebService::FootballData::Team.new(
    request => FakeRequest.new,
    links => {
        self => href => 'teams/5',
        fixtures => href => 'teams/5/fixtures',
        players => href => 'teams/5/players',
    },
);

# Team.id
is $team.id, 5, 'Get team id';

# Team.players
my @players;
lives-ok { @players = $team.players }, 'Get players of a team';
isa-ok @players[0], WebService::FootballData::Team::Player;
is @players[0].name, 'Manuel Neuer', 'Has the correct name';
is @players[0].position, 'Keeper', 'Has the correct position';
is @players[0].number, 1, 'Has the correct number';
is @players[0].nationality, 'Germany', 'Has the correct nationality';
is @players[0].birth_date.year, 1986, 'Has the correct birth date';
is @players[0].contract_date.year, 2019, 'Has the correct contract date';
is @players[0].market_value, '45,000,000 €', 'Has the correct market value';

# Team.fixtures
my @fixtures;
lives-ok { @fixtures = $team.fixtures }, 'Get fixtures of a team';
isa-ok @fixtures[0], WebService::FootballData::Fixtures::Fixture;
is @fixtures[0].matchday, 1, 'Has the correct matchday';
is @fixtures[0].home_team_name, 'FC Bayern München', 'Has the correct home_team_name';

my @fixtures_filtered;
lives-ok {
    @fixtures_filtered = $team.fixtures(
        :venue<away>, :season(2015), :timeframe<n4>
    )
}, 'Get fixtures of a team, filtered';
isa-ok @fixtures_filtered[0], WebService::FootballData::Fixtures::Fixture;
is @fixtures_filtered[0].date.Str, '2016-03-05T14:30:00Z', 'Has the correct date';
is @fixtures_filtered[0].status, 'TIMED', 'Has the correct status';
is @fixtures_filtered[0].matchday, 25, 'Has the correct matchday';
is @fixtures_filtered[0].away_team_name, 'FC Bayern München', 'Has the correct away_team_name';