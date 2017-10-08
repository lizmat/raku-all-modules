use v6;
use Test;
use lib 't/lib';
use FakeRequest;
use WebService::FootballData;

plan 156;

my $obj = WebService::FootballData.new;
can-ok $obj, 'request';
does-ok $obj.request, WebService::FootballData::Role::Request;
can-ok $obj, 'api_key';
isa-ok $obj.api_key, Str;

my $fd = WebService::FootballData.new: :request(FakeRequest.new);

{
    # Leagues
    can-ok $fd, 'leagues';
    my @leagues;
    lives-ok { @leagues = $fd.leagues }, 'Get leagues';
    isa-ok @leagues[0], WebService::FootballData::League;
    is @leagues[0].id, 351, 'League id is correctly set';
    is @leagues[0].name, '1. Bundesliga 2014/15', 'League name is correctly set';
    is @leagues[0].code, 'BL1', 'League code is correctly set';
    is @leagues[0].season, '2014', 'League season is correctly set';
    nok @leagues[0].current_matchday.defined, 'Current matchday is not set';
    is @leagues[0].number_of_matchdays, 34, 'Number of matchdays is correctly set';
    is @leagues[0].number_of_teams, 18, 'Number of teams is correctly set';
    is @leagues[0].number_of_games, 306, 'Number of games is correctly set';
    is @leagues[0].last_updated.day, 24, 'Last updated date is correctly set';

    my $leagues2013;
    lives-ok { $leagues2013 = $fd.leagues: :season(2013) }, 'Get the leagues from 2013';
    isa-ok $leagues2013[0], WebService::FootballData::League;
    is $leagues2013[0].season, '2013', 'League season is correctly set';
}

{
    # League
    can-ok $fd, 'league';
    my $premier_league;
    lives-ok { $premier_league = $fd.league: 'Premier league' }, 'Get a league by name';
    isa-ok $premier_league, WebService::FootballData::League;
    is $premier_league.code, 'PL', 'Has the correct code';

    isa-ok $fd.league('nonexistent'), Nil, 'Nonexistent league is Nil';

    my $bundesliga;
    lives-ok { $bundesliga = $fd.league(351) }, 'Get a league by id';
    isa-ok $bundesliga, WebService::FootballData::League;
    is $bundesliga.name, '1. Bundesliga 2014/15', 'Has the correct name';

    my $premier_league2013;
    lives-ok { $premier_league2013 = $fd.league: 'Premier league', :season(2013) }, 'Get a league by season and name';
    isa-ok $premier_league2013, WebService::FootballData::League;
    is $premier_league2013.name, 'Premier League 2013/14', 'Has the correct name';
}

{
    # Team
    can-ok $fd, 'team';
    # .team(Int)
    my $bayern;
    lives-ok { $bayern = $fd.team(5) }, 'Get a team by id';
    isa-ok $bayern, WebService::FootballData::Team;
    is $bayern.name, 'FC Bayern München', 'Has the correct name';
    is $bayern.short_name, 'Bayern', 'Has the correct short name';
    is $bayern.code, 'FCB', 'Has the correct code';
    is $bayern.squad_market_value, '551,250,000 €', 'Has the correct squad market value';
    is $bayern.crest_url, 'http://upload.wikimedia.org/wikipedia/commons/c/c5/Logo_FC_Bayern_München.svg', 'Has the correct crest URL';

    # .search_team
    can-ok $fd, 'search_team';
    my @manchester_search;
    lives-ok { @manchester_search = $fd.search_team: 'manchester' }, 'Search teams by name';
    isa-ok @manchester_search[1], WebService::FootballData::TeamSearchResult;
    is @manchester_search[1].team_id, 66, 'Has the correct team_id';
    is @manchester_search[1].team_name, 'Manchester United FC', 'Has the correct team_name';
    is @manchester_search[1].league_id, 354, 'Has the correct league_id';
    is @manchester_search[1].league_short_name, 'PL', 'Has the correct league_short_name';

    # .find_team
    can-ok $fd, 'find_team';
    my $manchester_find;
    lives-ok { $manchester_find = $fd.find_team: 'manchester' }, 'find team by name';
    isa-ok $manchester_find, WebService::FootballData::TeamSearchResult;
    is $manchester_find.team_id, 65, 'Has the correct team_id';

    # .team(Str)
    my $manchester_city;
    lives-ok { $manchester_city = $fd.team: 'manchester' }, 'Get a team by name';
    isa-ok $manchester_city, WebService::FootballData::Team;
    is $manchester_city.name, 'Manchester City FC', 'Has the correct name';

    isa-ok $fd.team('nonexistent'), Nil, 'Nonexistent team is Nil';
}

{
    # All Fixtures
    can-ok $fd, 'all_fixtures';
    my $all_fixtures;
    lives-ok { $all_fixtures = $fd.all_fixtures }, 'Get all fixtures';
    isa-ok $all_fixtures, WebService::FootballData::Fixtures::AllFixtures;
    is $all_fixtures.timeframe_start.Str, '2015-09-10', 'Has the correct timeframe_start';
    is $all_fixtures.timeframe_end.Str, '2015-09-16', 'Has the correct timeframe_end';
    my @fixtures;
    lives-ok { @fixtures = $all_fixtures.fixtures }, 'Get fixtures';
    is @fixtures[0].id, 145646, 'Has the correct id';
    is @fixtures[0].date.Str, '2015-08-29T16:30:00Z', 'Has the correct date';
    is @fixtures[0].status, 'TIMED', 'Has the correct status';
    is @fixtures[0].matchday, 3, 'Has the correct matchday';
    is @fixtures[0].home_team_name, 'FC Bayern München', 'Has the correct home_team_name';
    is @fixtures[0].away_team_name, 'Bayer Leverkusen', 'Has the correct away_team_name';
    is @fixtures[0].result.home_team_goals, -1, 'Has the correct home_team_goals';
    is @fixtures[0].result.away_team_goals, -1, 'Has the correct away_team_goals';
    my $all_fixtures_n14;
    lives-ok { $all_fixtures_n14 = $fd.all_fixtures: :timeframe<n14> }, 'Get all fixtures for the next 2 weeks';
    isa-ok $all_fixtures_n14, WebService::FootballData::Fixtures::AllFixtures;
    is $all_fixtures_n14.timeframe_start.Str, '2015-09-10', 'Has the correct timeframe_start';
    is $all_fixtures_n14.timeframe_end.Str, '2015-09-23', 'Has the correct timeframe_end';
    is $all_fixtures_n14.fixtures[1].matchday, 6, 'Has the correct matchday';
    my $all_fixtures_pl;
    lives-ok { $all_fixtures_pl = $fd.all_fixtures: :league<PL> }, 'Get all fixtures that belong to PL league';
    isa-ok $all_fixtures_pl, WebService::FootballData::Fixtures::AllFixtures;
    is $all_fixtures_pl.timeframe_start.Str, '2016-01-27', 'Has the correct timeframe_start';
    is $all_fixtures_pl.timeframe_end.Str, '2016-02-02', 'Has the correct timeframe_end';
    is $all_fixtures_pl.fixtures[0].matchday, 24, 'Has the correct matchday';
}

{
    # Fixture Details
    can-ok $fd, 'fixture_details';
    my $fixture_details;
    lives-ok { $fixture_details = $fd.fixture_details(136111) }, 'Get fixture details';
    isa-ok $fixture_details, WebService::FootballData::Fixtures::FixtureDetails;
    is $fixture_details.fixture.id, 136111, 'Has the correct id';
    is $fixture_details.fixture.date.Str, '2014-08-22T18:30:00Z', 'Has the correct date';
    is $fixture_details.fixture.status, 'FINISHED', 'Has the correct status';
    is $fixture_details.fixture.matchday, 1, 'Has the correct matchday';
    is $fixture_details.fixture.league_id, 351, 'Has the correct league_id';
    is $fixture_details.fixture.home_team_id, 5, 'Has the correct home_team_id';
    is $fixture_details.fixture.home_team_name, 'FC Bayern München', 'Has the correct home_team_name';
    is $fixture_details.fixture.away_team_id, 11, 'Has the correct away_team_id';
    is $fixture_details.fixture.away_team_name, 'VfL Wolfsburg', 'Has the correct away_team_name';
    is $fixture_details.fixture.result.home_team_goals, 2, 'Has the correct home_team_goals';
    is $fixture_details.fixture.result.away_team_goals, 1, 'Has the correct away_team_goals';
    is $fixture_details.head2head.timeframe_start.Str, '2010-08-20', 'Has the correct timeframe_start';
    is $fixture_details.head2head.timeframe_end.Str, '2015-01-30', 'Has the correct timeframe_end';
    is $fixture_details.head2head.home_team_wins, 8, 'Has the correct home_team_wins';
    is $fixture_details.head2head.away_team_wins, 1, 'Has the correct away_team_wins';
    is $fixture_details.head2head.draws, 1, 'Has the correct draws';
    is $fixture_details.head2head.home_team_last_win_home.perl, $fixture_details.fixture.perl, 'home_team_last_win_home is equal to the fixture';
    is $fixture_details.head2head.home_team_last_win.perl, $fixture_details.fixture.perl, 'home_team_last_win is equal to the fixture';
    nok $fixture_details.head2head.away_team_last_win_away.defined, 'away_team_last_win_away is not defined';
    is $fixture_details.head2head.away_team_last_win.id, 135958, 'Has the correct id';
    is $fixture_details.head2head.away_team_last_win.date.Str, '2015-01-30T19:30:00Z', 'Has the correct date';
    is $fixture_details.head2head.away_team_last_win.status, 'FINISHED', 'Has the correct status';
    is $fixture_details.head2head.away_team_last_win.matchday, 18, 'Has the correct matchday';
    is $fixture_details.head2head.away_team_last_win.home_team_name, 'VfL Wolfsburg', 'Has the correct home_team_name';
    is $fixture_details.head2head.away_team_last_win.away_team_name, 'FC Bayern München', 'Has the correct away_team_name';
    is $fixture_details.head2head.away_team_last_win.result.home_team_goals, 4, 'Has the correct home_team_goals';
    is $fixture_details.head2head.away_team_last_win.result.away_team_goals, 1, 'Has the correct away_team_goals';
    nok $fixture_details.head2head.fixtures[2].status.defined, 'Fixture has no status';

    my $fixture_details_h2h;
    lives-ok {
        $fixture_details_h2h = $fd.fixture_details: 136111, :head2head(2)
    }, 'Get fixture details with 2 head2heads';
    is $fixture_details_h2h.head2head.timeframe_start.Str, '2014-08-22', 'Has the correct timeframe_start';
    is $fixture_details_h2h.head2head.timeframe_end.Str, '2015-01-30', 'Has the correct timeframe_end';
    is $fixture_details_h2h.head2head.home_team_wins, 1, 'Has the correct home_team_wins';
    is $fixture_details_h2h.head2head.away_team_wins, 1, 'Has the correct away_team_wins';
    is $fixture_details_h2h.head2head.draws, 0, 'Has the correct draws';
}

{
    # players_of_team
    can-ok $fd, 'players_of_team';
    {
        my @players;
        lives-ok { @players = $fd.players_of_team(5) }, 'Get players of team 5';
        isa-ok @players[0], WebService::FootballData::Team::Player;
        is @players[0].number, 1, 'Has the correct number';
    }
    {
        my @players;
        lives-ok { @players = $fd.players_of_team: 'bayern' }, 'Get players of team Bayern';
        isa-ok @players[0], WebService::FootballData::Team::Player;
        is @players[0].number, 1, 'Has the correct number';
    }
}

{
    # fixtures_of_team
    can-ok $fd, 'fixtures_of_team';
    {
        my @fixtures;
        lives-ok { @fixtures = $fd.fixtures_of_team(5) }, 'Get fixtures of team 5';
        isa-ok @fixtures[0], WebService::FootballData::Fixtures::Fixture;
        is @fixtures[0].id, 136111, 'Has the correct id';
    }
    {
        my @fixtures;
        lives-ok { @fixtures = $fd.fixtures_of_team: 'bayern' }, 'Get fixtures of team Bayern';
        isa-ok @fixtures[0], WebService::FootballData::Fixtures::Fixture;
        is @fixtures[0].id, 136111, 'Has the correct id';
    }

    {
        my @fixtures_filtered;
        lives-ok {
            @fixtures_filtered = $fd.fixtures_of_team: 5, :venue<away>, :season(2015), :timeframe<n4>
        }, 'Get fixtures of team 5, filtered';
        isa-ok @fixtures_filtered[0], WebService::FootballData::Fixtures::Fixture;
        is @fixtures_filtered[0].id, 145448, 'Has the correct id';
    }
    {
        my @fixtures_filtered;
        lives-ok {
            @fixtures_filtered = $fd.fixtures_of_team: 'bayern', :venue<away>, :season(2015), :timeframe<n4>
        }, 'Get fixtures of team Bayern, filtered';
        isa-ok @fixtures_filtered[0], WebService::FootballData::Fixtures::Fixture;
        is @fixtures_filtered[0].id, 145448, 'Has the correct id';
    }
}

{
    # fixtures_of_league
    can-ok $fd, 'fixtures_of_league';
    my @fixtures;
    lives-ok { @fixtures = $fd.fixtures_of_league(351) }, 'Get fixtures of league 351';
    isa-ok @fixtures[0], WebService::FootballData::Fixtures::Fixture;
    is @fixtures[0].id, 136111, 'Has the correct id';

    my @fixtures_p80;
    lives-ok {
        @fixtures_p80 = $fd.fixtures_of_league: 351, :timeframe('p80')
    }, 'Get fixtures of league 351, filtered by timeframe';
    isa-ok @fixtures_p80[0], WebService::FootballData::Fixtures::Fixture;
    is @fixtures_p80[0].id, 135823, 'Has the correct id';
    
    my @fixtures_m10;
    lives-ok {
        @fixtures_m10 = $fd.fixtures_of_league: 351, :matchday(10)
    }, 'Get fixtures of league 351, filtered by matchday';
    isa-ok @fixtures_m10[0], WebService::FootballData::Fixtures::Fixture;
    is @fixtures_m10[0].id, 136022, 'Has the correct id';
}

{
    # teams_of_league
    can-ok $fd, 'teams_of_league';
    my @teams;
    lives-ok { @teams = $fd.teams_of_league(351) }, 'Get teams of league 351';
    isa-ok @teams[0], WebService::FootballData::Team;
    is @teams[0].name, 'FC Bayern München', 'Has the correct name';
}

{
    # table_of_league
    can-ok $fd, 'table_of_league';
    my $table;
    lives-ok { $table = $fd.table_of_league(351) }, 'Get table of league 351';
    isa-ok $table, WebService::FootballData::League::Table;
    is $table.name, '1. Bundesliga 2014/15', 'Has the correct name';

    my $table_d5;
    lives-ok { $table_d5 = $fd.table_of_league: 351, :matchday(5) }, 'Get matchday 5 table of league 351';
    isa-ok $table_d5, WebService::FootballData::League::Table;
    is $table_d5.name, '1. Bundesliga 2014/15', 'Has the correct name';
    is $table_d5.matchday, 5, 'Has the correct matchday';
}