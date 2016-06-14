use v6.c;

use WebService::FootballData;
use Text::Table::Simple;

unit class App::Football:ver(v0.1.1);

my $.program_name = 'football';

has $.fd = WebService::FootballData.new;

method team ($team_name) {
    my $team = $!fd.team: $team_name;

    self!not_found: 'Team' unless $team;

    self!print_teams: $team;

    $team;
}

method team_players ($team_name) {
    my $team = self.team: $team_name;
    my $players = $team.players;

    self!not_found: 'Players' unless $players;

    my @cols = <# Player Position Age Birthdate Nationality Contract Value>;
    my @rows = $players.map: {
        .number, .name, .position, .age, ~.birth_date, .nationality, .contract_date.year, .market_value
    }

    self!print_table: @cols, @rows;
}

method team_fixtures ($team_name, :$season, :$timeframe, :$venue) {
    my $team = self.team: $team_name;
    my $fixtures = $team.fixtures: :$season, :$timeframe, :$venue;

    self!not_found: 'Fixtures' unless $fixtures;

    self!print_fixtures: $fixtures;
}

method leagues (:$season) {
    my $leagues = $!fd.leagues: :$season;

    self!print_leagues: $leagues;
}

method league ($league_name, :$season) {
    my $league = $!fd.league: $league_name, :$season;

    self!not_found: 'League' unless $league;

    self!print_leagues: $league;

    $league;
}

method league_teams ($league_name, :$season) {
    my $league = self.league: $league_name, :$season;

    my $teams = $league.teams;

    self!not_found: 'Teams' unless $teams;

    self!print_teams: $teams.sort: *.name;
}

method league_table ($league_name, :$season, :$matchday) {
    my $league = self.league: $league_name, :$season;

    say "Matchday $_" with $matchday;

    my $league_table = $league.table($matchday).rows;

    self!not_found: 'Table' unless $league_table;

    my @cols = <Pos Team Pts Pld GF GA GD W D L HW HD HL AW AD AL>;
    my @rows = $league_table.map: {
        .position, .name, .points, .games_played, .goals_for, .goals_against, .goal_difference,
        .wins, .draws, .losses, .home.wins, .home.draws, .home.losses, .away.wins, .away.draws, .away.losses
    };

    self!print_table: @cols, @rows;
}

method league_fixtures ($league_name, :$season, :$matchday, :$timeframe) {
    my $league = self.league: $league_name, :$season;

    say "Matchday $_" with $matchday;

    my $fixtures = $league.fixtures: :$matchday, :$timeframe;

    self!not_found: 'Fixtures' unless $fixtures;

    self!print_fixtures: $fixtures;
}

method all_fixtures (:$timeframe, :$league-code) {
    my Str $league = .uc with $league-code;

    my $fixtures = $!fd.all_fixtures(:$timeframe, :$league).fixtures;

    self!not_found: 'Fixtures' unless $fixtures;

    self!print_fixtures: $fixtures;
}

method !print_teams ($teams) {
    my @cols = «Team 'Short Name' Code 'Squad Value'»;
    my @rows = $teams.map: { .name, .short_name, .code, .squad_market_value };

    self!print_table: @cols, @rows;
}

method !print_leagues ($leagues) {
    my @cols = <League Code Season Matchday Matchdays Teams Games>;
    my @rows = $leagues.map: { .name, .code, .season, .current_matchday, .number_of_matchdays, .number_of_teams, .number_of_games };

    self!print_table: @cols, @rows;
}

method !print_fixtures (@fixtures) {
    my @cols = «Day 'Home Team' HG AG 'Away Team' Status 'Date & Time'»;
    my @rows = @fixtures.map: {
        .matchday, .home_team_name, .result.home_team_goals,
        .result.away_team_goals, .away_team_name,
        .status, self!format_date(.date.local)
    }

    self!print_table: @cols, @rows;
}

method !print_table (@cols, @rows) {
    say lol2table(@cols, @rows).join: "\n";
}

method !format_date (DateTime $date_time) returns Str {
    sprintf '%s %02d:%02d', .yyyy-mm-dd, .hour, .minute given $date_time;
}

method !not_found (Str $resource) {
    "{self.program_name}: $resource not found".note and exit;
}

=begin pod

=head1 NAME

App::Football - Contains methods for football program

=head1 SYNOPSIS

=begin code

use App::Football;

# Print football leagues
App::Football.new.leagues;

=end code

=head1 DESCRIPTION

Class used by football script. It's not intended to be used by users.

=head1 ATTRIBUTES

=head2 program_name

A class attribute containing the program name.

=head2 fd

An instance of C<WebService::FootballData>.

=head1 METHODS

=head2 team

    $f.team: 'bayern';

Takes a team name.

Prints team's data.

Returns the team object.

=head2 team_players

    $f.team_players: 'bayern';

Takes a team name.

Prints team's data and a list of its players and their data.

=head2 team_fixtures

    $f.team_fixtures: 'bayern';

Takes:

=item team name

=item Named argument C<season>

=item Named argument C<timeframe>

=item Named argument C<venue>

Prints team's data and a list of its fixtures and their data.

=head2 leagues

    $f.leagues;

Takes named argument C<season>.

Prints a list of leagues and their data.

=head2 league

    $f.league: 'pd';

Takes:

=item league name

=item Named argument C<season>

Prints league's data.

Returns the league object.

=head2 league_teams

    $f.league_teams: 'pd';

Takes:

=item league name

=item Named argument C<season>

Prints league's data and a list of its teams and their data.

=head2 league_table

    $f.league_table: 'pd';

Takes:

=item league name

=item Named argument C<season>

=item Named argument C<matchday>

Prints league's data and its table.

=head2 league_fixtures

    $f.league_fixtures: 'pd';

Takes:

=item league name

=item Named argument C<season>

=item Named argument C<matchday>

=item Named argument C<timeframe>

Prints league's data and a list of its fixtures and their data.

=head2 all_fixtures

    $f.all_fixtures;

Takes:

=item Named argument C<timeframe>

=item Named argument C<league-code>

Prints a list of all fixtures from all leagues and their data.

=head1 AUTHOR

Siavash Askari Nasr - L<http://ciavash.name/>

=head1 COPYRIGHT AND LICENSE

Copyright © 2016 Siavash Askari Nasr

This file is part of App::Football.

App::Football is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

App::Football is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with App::Football.  If not, see <http://www.gnu.org/licenses/>.

=end pod