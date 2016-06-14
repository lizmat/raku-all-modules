unit role WebService::FootballData::Role::CommonTableStats;

has Int $.goals_for;
has Int $.goals_against;
has Int $.wins;
has Int $.draws;
has Int $.losses;

=begin pod

=head1 NAME

WebService::FootballData::Role::CommonTableStats - Role representing common table stats

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Role::CommonTableStats;

unit class WebService::FootballData::League::Table::Row;
also does WebService::FootballData::Role::CommonTableStats;

=end code

=head1 DESCRIPTION

Role for creating common table stats.

Class L<WebService::FootballData::League::Table::Row> makes use of this role.

=head1 ATTRIBUTES

=head2 goals_for

Number of goals the team has scored, of type C<Int>.

=head2 goals_against

Number of goals the team has conceded, of type C<Int>.

=head2 wins

Number of the team's wins, of type C<Int>.

=head2 draws

Number of the team's draws, of type C<Int>.

=head2 losses

Number of the team's losses, of type C<Int>.

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