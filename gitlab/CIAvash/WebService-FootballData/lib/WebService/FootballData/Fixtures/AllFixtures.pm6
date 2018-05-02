use WebService::FootballData::Role::HasFixtures;

unit class WebService::FootballData::Fixtures::AllFixtures;

also does WebService::FootballData::Role::HasFixtures;

=begin pod

=head1 NAME

WebService::FootballData::Fixtures::AllFixtures - Class for managing all fixtures

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Fixtures::AllFixtures;

my $all_fixtures = WebService::FootballData::Fixtures::AllFixtures.new(
    fixtures => @fixtures
);

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for accessing a list of all fixtures from all leagues.

=head1 ATTRIBUTES

=head2 timeframe_start

Starting date of timeframe, of type C<Date>.

=head2 timeframe_end

Ending date of timeframe, of type C<Date>.

=head2 fixtures

Fixtures, Array of L<WebService::FootballData::Fixtures::Fixture> instances.

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