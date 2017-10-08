unit class WebService::FootballData::Fixtures::Fixture::Result;

has Int $.home_team_goals;
has Int $.away_team_goals;

=begin pod

=head1 NAME

WebService::FootballData::Fixtures::Fixture::Result - Class representing a football fixture result

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Fixtures::Fixture::Result;

my $result = WebService::FootballData::Fixtures::Fixture::Result.new(
    home_team_goals => 3,
    away_team_goals => 0
);

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for accessing fixture result data.

=head1 ATTRIBUTES

=head2 home_team_goals

Home team goals, of type C<Int>.

=head2 away_team_goals

Away team goals, of type C<Int>.

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