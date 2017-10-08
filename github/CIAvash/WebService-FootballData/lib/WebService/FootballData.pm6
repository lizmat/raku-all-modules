use v6.c;

use WebService::FootballData::Role::Request;
use WebService::FootballData::Request;
use WebService::FootballData::Role::Factory::MakeTeam;
use WebService::FootballData::Role::Factory::MakeLeague;
use WebService::FootballData::Role::Factory::MakeTable;
use WebService::FootballData::Role::Factory::MakeTeamSearchResult;
use WebService::FootballData::Role::Factory::MakeFixture;
use WebService::FootballData::Role::Factory::MakePlayer;

unit class WebService::FootballData;

also does WebService::FootballData::Role::Factory::MakeTeam;
also does WebService::FootballData::Role::Factory::MakeLeague;
also does WebService::FootballData::Role::Factory::MakeTable;
also does WebService::FootballData::Role::Factory::MakeTeamSearchResult;
also does WebService::FootballData::Role::Factory::MakeFixture;
also does WebService::FootballData::Role::Factory::MakePlayer;

has Str $.api_key;
has WebService::FootballData::Role::Request $.request = WebService::FootballData::Request.new: :$!api_key;

# TODO: uncomment `returns` when RT 127309 is fixed
method leagues (Int :$season) #`(returns Array of WebService::FootballData::League) {
    if self!get_leagues(:$season) -> $_ {
        self!make_leagues: $_;
    }
    else { Nil }
}

multi method league (Int $id) returns WebService::FootballData::League {
    if $!request.get("soccerseasons/$id").hash -> $_ {
        self!make_league: $_;
    }
    else { Nil }
}

multi method league (Str $name, Int :$season) returns WebService::FootballData::League {
    if self!get_leagues(:$season) -> $_ {
        my %league = .first({ (.<caption>, .<league>) ~~ m:i/$name/ }).hash;
        if %league -> $_ {
            return self!make_league: $_;
        }
    }
    Nil;
}

method !get_leagues (Int :$season) returns Array of Hash {
    my %params = :$season if $season.defined;
    Array[Hash].new: |$!request.get('soccerseasons', :%params).list;
}

multi method team (Int $id) returns WebService::FootballData::Team {
    if $!request.get("teams/$id").hash -> $_ {
        self!make_team: $_;
    }
    else { Nil }
}

multi method team (Str $name) returns WebService::FootballData::Team {
    with self.find_team($name) {
        self.team: .team_id;
    }
    else { Nil }
}

# TODO: uncomment `returns` when RT 127309 is fixed
method search_team (Str $name) #`(returns Array of WebService::FootballData::TeamSearchResult) {
    if self!search_teams($name) -> $_ {
        self!make_team_search_results: $_;
    }
    else { Nil }
}

# Return the first result of team search
method find_team (Str $name) returns WebService::FootballData::TeamSearchResult {
    if self!search_teams($name) -> $_ {
        self!make_team_search_result: .[0].hash;
    }
    else { Nil }
}

method !search_teams (Str $name) returns Array {
    $!request.get('teams', :params(:$name))<teams>.list;
}

method all_fixtures (Str :$timeframe, Str :$league) returns WebService::FootballData::Fixtures::AllFixtures {
    my %params = (:timeFrame($timeframe), :$league).grep: *.value.defined;
    if $!request.get('fixtures', :%params).hash -> $_ {
        self!make_all_fixtures: $_;
    }
    else { Nil }
}

method fixture_details (Int $id, Int :$head2head) returns WebService::FootballData::Fixtures::FixtureDetails {
    my %params = :$head2head if $head2head.defined;
    if $!request.get("fixtures/$id", :%params).hash -> $_ {
        self!make_fixture_details: $_;
    }
    else { Nil }
}

# TODO: uncomment `returns` when RT 127309 is fixed
multi method players_of_team (Int $id) #`(returns Array of WebService::FootballData::Team::Player) {
    if $!request.get("teams/$id/players")<players>.list -> $_ {
        self!make_players: $_;
    }
    else { Nil }
}

# TODO: uncomment `returns` when RT 127309 is fixed
multi method players_of_team (Str $name) #`(returns Array of WebService::FootballData::Team::Player) {
    with self.find_team($name) {
        self.players_of_team: .team_id;
    }
    else { Nil }
}

# TODO: uncomment `returns` when RT 127309 is fixed
multi method fixtures_of_team (Int $id, Int :$season, Str :$timeframe, Str :$venue) #`(returns Array of WebService::FootballData::Fixtures::Fixture) {
    my %params = (:$season, :timeFrame($timeframe), :$venue).grep: *.value.defined;
    if $!request.get("teams/$id/fixtures", :%params)<fixtures>.list -> $_ {
        self!make_fixtures: $_;
    }
    else { Nil }
}

# TODO: uncomment `returns` when RT 127309 is fixed
multi method fixtures_of_team (Str $name, Int :$season, Str :$timeframe, Str :$venue) #`(returns Array of WebService::FootballData::Fixtures::Fixture) {
    with self.find_team($name) {
        self.fixtures_of_team: .team_id, :$season, :$timeframe, :$venue;
    }
    else { Nil }
}

# TODO: uncomment `returns` when RT 127309 is fixed
method fixtures_of_league (Int $id, Int :$matchday, Str :$timeframe) #`(returns Array of WebService::FootballData::Fixtures::Fixture) {
    my %params = (:$matchday, :timeFrame($timeframe)).grep: *.value.defined;
    if $!request.get("soccerseasons/$id/fixtures", :%params)<fixtures>.list -> $_ {
        self!make_fixtures: $_;
    }
    else { Nil }
}

# TODO: uncomment `returns` when RT 127309 is fixed
method teams_of_league (Int $id) #`(returns Array of WebService::FootballData::Team) {
    if $!request.get("soccerseasons/$id/teams")<teams>.list -> $_ {
        self!make_teams: $_;
    }
    else { Nil }
}

method table_of_league (Int $id, :$matchday) returns WebService::FootballData::League::Table {
    my %params = :$matchday if $matchday.defined;
    if $!request.get("soccerseasons/$id/leagueTable", :%params).hash -> $_ {
        self!make_table: $_;
    }
    else { Nil }
}

=begin pod

=head1 NAME

WebService::FootballData - Interface to football-data.org API

=head1 SYNOPSIS

=begin code

use WebService::FootballData;

my $fd = WebService::FootballData.new;
say .name for $fd.leagues;

my $league = $fd.league: 'premier league';
say "#{.position} in $league.name() is {.name} with {.points} points" given $league.table.rows[0];

my $team = $fd.team: 'manchester city';
say $team.name ~ ' players:';
say .name for $team.players;

my @fixtures = $team.fixtures;
given @fixtures[0] {
    say .home_team_name ~ ': ' ~ .result.home_team_goals;
    say .away_team_name ~ ': ' ~ .result.away_team_goals;
}

=end code

=head1 DESCRIPTION

L<WebService::FootballData> provides a Perl 6 interface to football-data.org API.

=head1 ATTRIBUTES

=head2 api_key

    my $fd = WebService::FootballData.new: :api_key<YOUR_API_KEY>;

A C<Str> value. The API key provided by football-data.org.

=head2 request

An object that does the L<WebService::FootballData::Role::Request> role.
Defaults to an instance of L<WebService::FootballData::Request>.

=head1 METHODS

=head2 leagues

    $fd.leagues;
    $fd.leagues: :season(2014);

Takes named argument C<season> of type C<Int>.

Returns Array of L<WebService::FootballData::League> instances.

=head2 league

Multi method.

    $fd.league: 351;

Takes league ID of type C<Int>.

    $fd.league: 'pl';
    $fd.league: 'pl', :season(2014);

Takes:

=item League name of type C<Str>

=item Named argument C<season> of type C<Int>

Returns instance of L<WebService::FootballData::League>.

=head2 team

Multi method.

    $fd.team: 5;

Takes team ID of type C<Int>.

    $fd.team: 'manchester city';

Takes team name of type C<Str>.

Returns instance of L<WebService::FootballData::Team>.

=head2 search_team

    $fd.search_team: 'manchester';

Takes team name of type C<Str>.

Returns Array of L<WebService::FootballData::TeamSearchResult> instances.

=head2 find_team

    $fd.find_team: 'manchester';

Takes team name of type C<Str>.

Returns the first team search result found: instance of L<WebService::FootballData::TeamSearchResult>.

=head2 all_fixtures

    $fd.all_fixtures: :timeframe<n7>, :league<PL,CL>;

Takes:

=item Named argument C<timeframe> of type C<Str>.
A timeframe as defined by football-data.org.

=item Named argument C<league> of type C<Str>.
A league code as defined by football-data.org.

Returns instance of L<WebService::FootballData::Fixtures::AllFixtures>.

=head2 fixture_details

    $fd.fixture_details: 136111;
    $fd.fixture_details: 136111, :head2head(3);

Takes:

=item Fixture ID of type C<Int>.

=item Named argument C<head2head> of type C<Int>.
Number of former games to be analyzed.

Returns instance of L<WebService::FootballData::Fixtures::FixtureDetails>.

=head2 players_of_team

Multi method.

    $fd.players_of_team: 5;

Takes team ID of type C<Int>.

    $fd.players_of_team: 'manchester city';

Takes team name of type C<Str>.

Returns Array of L<WebService::FootballData::Team::Player> instances.

=head2 fixtures_of_team

Multi method.

    $fd.fixtures_of_team: 5, :timeframe<p20>;
    $fd.fixtures_of_team: 5, :season(2014), :venue<home>;

Takes:

=item Team ID of type C<Int>.

=item Named argument C<season> of type C<Int>.

=item Named argument C<timeframe> of type C<Str>.
A timeframe as defined by football-data.org.

=item Named argument C<venue> of type C<Str>.
A venue as defined by football-data.org.

    $fd.fixtures_of_team: 'mancity', :timeframe<p20>;
    $fd.fixtures_of_team: 'mancity', :season(2014), :venue<home>;

Takes:

=item Team name of type C<Str>.

=item Named argument C<season> of type C<Int>.

=item Named argument C<timeframe> of type C<Str>.
A timeframe as defined by football-data.org.

=item Named argument C<venue> of type C<Str>.
A venue as defined by football-data.org.

Returns Array of L<WebService::FootballData::Fixtures::Fixture> instances.

=head2 fixtures_of_league

Multi method.

    $fd.fixtures_of_league: 351, :timeframe<p20>;
    $fd.fixtures_of_league: 351, :matchday(5);

Takes:

=item League ID of type C<Int>.

=item Named argument C<matchday> of type C<Int>.

=item Named argument C<timeframe> of type C<Str>.
A timeframe as defined by football-data.org.

    $fd.fixtures_of_league: 'pl', :timeframe<p20>;
    $fd.fixtures_of_league: 'pl', :matchday(5);

Takes:

=item League name of type C<Str>.

=item Named argument C<matchday> of type C<Int>.

=item Named argument C<timeframe> of type C<Str>.
A timeframe as defined by football-data.org.

Returns Array of L<WebService::FootballData::Fixtures::Fixture> instances.

=head2 teams_of_league

Multi method.

    $fd.teams_of_league: 351;

Takes league ID of type C<Int>.

Returns Array of L<WebService::FootballData::Team> instances.

=head2 table_of_league

Multi method.

    $fd.table_of_league: 351;
    $fd.table_of_league: 351, :matchday(5);

Takes:

=item League ID of type C<Int>.

=item Named argument C<matchday> of type C<Int>.

Returns instance of L<WebService::FootballData::League::Table>.

=head1 ERRORS

C<HTTP::UserAgent> module is used with exception throwing enabled.
So exceptions will be thrown in case of non-existent resources, out of range values, etc.
See L<http://modules.perl6.org/dist/HTTP::UserAgent>
and L<WebService::FootballData::Facade::UserAgent>

=head1 ENVIRONMENT

Some live tests will run when C<NETWORK_TESTING> environment variable is set.

=head1 REPOSITORY

L<https://gitlab.com/CIAvash/WebService-FootballData>

=head1 BUGS

L<https://gitlab.com/CIAvash/WebService-FootballData/issues>

=head1 AUTHOR

Siavash Askari Nasr - L<http://ciavash.name/>

=head1 COPYRIGHT AND LICENSE

Copyright © 2016 Siavash Askari Nasr

This file is part of WebService::FootballData.

WebService::FootballData is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

WebService::FootballData is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with WebService::FootballData.  If not, see <http://www.gnu.org/licenses/>.

=end pod