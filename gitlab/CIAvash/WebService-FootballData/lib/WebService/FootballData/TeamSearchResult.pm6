unit class WebService::FootballData::TeamSearchResult;

has Int $.team_id;
has Str $.team_name;
has Int $.league_id;
has Str $.league_short_name;

=begin pod

=head1 NAME

WebService::FootballData::TeamSearchResult - Class representing a team search result

=head1 SYNOPSIS

=begin code

use WebService::FootballData::TeamSearchResult;

my $search_result = WebService::FootballData::TeamSearchResult.new(
    team_id => '65',
    team_name => 'Manchester City FC'
);

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for managing team search result.

C<search_team> and C<find_team> methods of L<WebService::FootballData> make use of team search result objects.

=head1 ATTRIBUTES

=head2 team_id

Team's ID, of type C<Int>.

=head2 team_name

Team's name, of type C<Str>.

=head2 league_id

ID of the league the team belongs to, of type C<Int>.

=head2 league_short_name

Name of the league the team belongs to, of type C<Str>.

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