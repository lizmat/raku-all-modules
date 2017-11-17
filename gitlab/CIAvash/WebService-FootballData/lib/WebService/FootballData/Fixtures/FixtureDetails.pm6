use WebService::FootballData::Fixtures::Fixture;
use WebService::FootballData::Fixtures::Head2Head;

unit class WebService::FootballData::Fixtures::FixtureDetails;

has WebService::FootballData::Fixtures::Fixture $.fixture;
has WebService::FootballData::Fixtures::Head2Head $.head2head;

=begin pod

=head1 NAME

WebService::FootballData::Fixtures::FixtureDetails - Class for managing a fixture and its head to head data

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Fixtures::FixtureDetails;

my $result = WebService::FootballData::Fixtures::FixtureDetails.new(
    fixture => $fixture,
    head2head => $head2head
);

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for accessing fixture and head to head data.

=head1 ATTRIBUTES

=head2 fixture

Fixture, instance of L<WebService::FootballData::Fixtures::Fixture>.

=head2 head2head

Previous fixtures between the 2 teams, instance of L<WebService::FootballData::Fixtures::Head2Head>.

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