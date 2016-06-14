use WebService::FootballData::Fixtures::Fixture::Result;
use WebService::FootballData::Role::ID;

unit class WebService::FootballData::Fixtures::Fixture;

also does WebService::FootballData::Role::ID;

has DateTime $.date;
has Str $.status;
has Int $.matchday;
has Str $.home_team_name;
has Str $.away_team_name;
has WebService::FootballData::Fixtures::Fixture::Result $.result;

method league_id returns Int {
    self!extract_id: %!links<soccerseason><href>;
}

method home_team_id returns Int {
    self!extract_id: %!links<homeTeam><href>;
}

method away_team_id returns Int {
    self!extract_id: %!links<awayTeam><href>;
}

=begin pod

=head1 NAME

WebService::FootballData::Fixtures::Fixture - Class representing a football fixture

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Fixtures::Fixture;

my $fixture = WebService::FootballData::Fixtures::Fixture.new(
    request => WebService::FootballData::Request.new,
    links => {
        self => href => "fixtures/136111",
        soccerseason => href => "soccerseason/136111"
        homeTeam => href => "teams/5",
        awayTeam => href => "teams/11",
    }
);

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for accessing fixture data.

=head1 ATTRIBUTES

=head2 date

Fixture's date, of type C<DateTime>.

=head2 status

Fixture's status, of type C<Str>.

=head2 matchday

Fixture's matchday, of type C<Int>.

=head2 home_team_name

Fixture's home team name, of type C<Str>.

=head2 away_team_name

Fixture's away team name, of type C<Str>.

=head2 result

Fixture's result, instance of L<WebService::FootballData::Fixtures::Fixture::Result>.

=head1 METHODS

=head2 league_id

    $fixture.league_id;

Returns fixture's league id, of type C<Int>.

=head2 home_team_id

    $fixture.home_team_id;

Returns fixture's home team id, of type C<Int>.

=head2 away_team_id

    $fixture.away_team_id;

Returns fixture's away team id, of type C<Int>.

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