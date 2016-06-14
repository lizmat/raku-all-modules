use WebService::FootballData::Role::HasRequest;
use WebService::FootballData::Role::ID;
use WebService::FootballData::Role::Factory::MakePlayer;
use WebService::FootballData::Role::Factory::MakeFixture;

unit class WebService::FootballData::Team;

also does WebService::FootballData::Role::HasRequest;
also does WebService::FootballData::Role::ID;
also does WebService::FootballData::Role::Factory::MakePlayer;
also does WebService::FootballData::Role::Factory::MakeFixture;

has Str $.name;
has Str $.short_name;
has Str $.code;
has Str $.squad_market_value;
has Str $.crest_url;

# TODO: uncomment `returns` when RT 127309 is fixed
method players #`(returns Array of WebService::FootballData::Team::Player) {
    if $!request.get(%!links<players><href>)<players>.list -> $_ {
        self!make_players: $_;
    }
    else { Nil }
}

# TODO: uncomment `returns` when RT 127309 is fixed
method fixtures (Int :$season, Str :$timeframe, Str :$venue) #`(returns Array of WebService::FootballData::Fixtures::Fixture) {
    my %params = (:$season, :timeFrame($timeframe), :$venue).grep: *.value.defined;
    if $!request.get(%!links<fixtures><href>, :%params)<fixtures>.list -> $_ {
        self!make_fixtures: $_;
    }
    else { Nil }
}

=begin pod

=head1 NAME

WebService::FootballData::Team - Class representing a football team

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Team;

my $team = WebService::FootballData::Team.new(
    request => WebService::FootballData::Request.new,
    links => {
        self => href => "teams/65",
        fixtures => href => "teams/65/fixtures"
        players => href => "teams/65/players",
    },
    name => 'Manchester City FC'
);

my @players = $team.players;

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for accessing team data.

C<team> method of L<WebService::FootballData> and C<teams> method
of L<WebService::FootballData::League> make use of team objects.

=head1 ATTRIBUTES

=head2 request

An object that does the L<WebService::FootballData::Role::Request> role.

This is a required attribute.

=head2 links

A hash containing links provided by football-data.org.

This is a required attribute.

=head2 name

Name of the team, of type C<Str>.

=head2 short_name

Short name of the team, of type C<Str>.

=head2 code

Code of the team, of type C<Str>.

=head2 squad_market_value

Squad market value of the team, of type C<Str>.

=head2 crest_url

Crest URL of the team, of type C<Str>.

=head1 METHODS

=head2 id

    $team.id;

Returns the team's id, of type C<Int>.

=head2 players

    $team.players;

Returns the team's players: Array of L<WebService::FootballData::Team::Player> instances.

=head2 fixtures

    $team.fixtures: :timeframe<p20>;
    $team.fixtures: :season(2014), :venue<home>;

Takes:

=item Named argument C<season> of type C<Int>.

=item Named argument C<timeframe> of type C<Str>.
A timeframe as defined by football-data.org.

=item Named argument C<venue> of type C<Str>.
A venue as defined by football-data.org.

Returns the team's fixtures: Array of L<WebService::FootballData::Fixtures::Fixture> instances.

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