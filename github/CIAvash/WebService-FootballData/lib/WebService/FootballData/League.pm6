use WebService::FootballData::Role::HasRequest;
use WebService::FootballData::Role::ID;
use WebService::FootballData::Role::Factory::MakeTeam;
use WebService::FootballData::Role::Factory::MakeTable;
use WebService::FootballData::Role::Factory::MakeFixture;

unit class WebService::FootballData::League;

also does WebService::FootballData::Role::HasRequest;
also does WebService::FootballData::Role::ID;
also does WebService::FootballData::Role::Factory::MakeTeam;
also does WebService::FootballData::Role::Factory::MakeTable;
also does WebService::FootballData::Role::Factory::MakeFixture;

has Str $.name;
has Str $.code;
has Str $.season;
has Int $.current_matchday;
has Int $.number_of_matchdays;
has Int $.number_of_teams;
has Int $.number_of_games;
has DateTime $.last_updated;

# TODO: uncomment `returns` when RT 127309 is fixed
method teams #`(returns Array of WebService::FootballData::Team) {
    if $!request.get(%!links<teams><href>)<teams>.list -> $_ {
        self!make_teams: $_;
    }
    else { Nil }
}

method table (Int $matchday?) returns WebService::FootballData::League::Table {
    my %params = :$matchday if $matchday.defined;
    if $!request.get(%!links<leagueTable><href>, :%params).hash -> $_ {
        self!make_table: $_;
    }
    else { Nil }
}

# TODO: uncomment `returns` when RT 127309 is fixed
method fixtures (Int :$matchday, Str :$timeframe) #`(returns Array of WebService::FootballData::Fixtures::Fixture) {
    my %params = (:$matchday, :timeFrame($timeframe)).grep: *.value.defined;
    if $!request.get(%!links<fixtures><href>, :%params)<fixtures>.list -> $_ {
        self!make_fixtures: $_;
    }
    else { Nil }
}

=begin pod

=head1 NAME

WebService::FootballData::League - Class representing a football league

=head1 SYNOPSIS

=begin code

use WebService::FootballData::League;

my $league = WebService::FootballData::League.new(
    request => WebService::FootballData::Request.new,
    links => {
        self => href => "soccerseasons/351",
        teams => href => "soccerseasons/351/teams",
        fixtures => href => "soccerseasons/351/fixtures",
        leagueTable => href => "soccerseasons/351/leagueTable"
    },
    name => '1. Bundesliga 2014/15'
);

my @teams = $league.teams;

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for accessing league data.

C<leagues> and C<league> methods of L<WebService::FootballData> make use of league objects.

=head1 ATTRIBUTES

=head2 request

An object that does the L<WebService::FootballData::Role::Request> role.

This is a required attribute.

=head2 links

A hash containing links provided by football-data.org.

This is a required attribute.

=head2 name

Name of the league, of type C<Str>.

=head2 code

Code of the league, of type C<Str>.

=head2 season

Season of the league, of type C<Str>.

=head2 current_matchday

Current matchday of the league, of type C<Int>.

=head2 number_of_matchdays

Number of the matchdays of the league, of type C<Int>.

=head2 number_of_teams

Number of the teams of the league, of type C<Int>.

=head2 number_of_games

Number of total games of the league, of type C<Int>.

=head2 last_updated

Date of when the league's data was updated, of type C<DateTime>.

=head1 METHODS

=head2 id

    $league.id;

Returns the league's id, of type C<Int>.

=head2 teams

    $league.teams;

Returns teams of the league: Array of L<WebService::FootballData::Team> instances.

=head2 table

    $league.table;
    $league.table: 5;

Takes optional positional argument matchday of type C<Int>.

Returns the league's table: instance of L<WebService::FootballData::League::Table>.

=head2 fixtures

    $league.fixtures: :timeframe<p20>;
    $league.fixtures: :matchday(5);

Takes:

=item Named argument C<matchday> of type C<Int>.

=item Named argument C<timeframe> of type C<Str>.
A timeframe as defined by football-data.org.

Returns the league's fixtures: Array of L<WebService::FootballData::Fixtures::Fixture> instances.

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