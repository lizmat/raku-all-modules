use WebService::FootballData::Role::ID;
use WebService::FootballData::Role::CommonTableStats;

unit class WebService::FootballData::League::Table::Row;

also does WebService::FootballData::Role::ID['team'];
also does WebService::FootballData::Role::CommonTableStats;

class Home does WebService::FootballData::Role::CommonTableStats {}
class Away does WebService::FootballData::Role::CommonTableStats {}

has Str $.name;
has Str $.crest_url;
has Int $.position;
has Int $.games_played;
has Int $.goal_difference;
has Home $.home;
has Away $.away;
has Int $.points;

=begin pod

=head1 NAME

WebService::FootballData::League::Table::Row - Class representing a team's table stats

=head1 SYNOPSIS

=begin code

use WebService::FootballData::League::Table::Row;

my $standing = WebService::FootballData::League::Table::Row.new(
    name => 'Leicester City FC',
    position => 1
);

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for accessing team's table stats.

C<rows> method of L<WebService::FootballData::League::Table> makes use of row objects.

=head1 ATTRIBUTES

=head2 name

Name of the team, of type C<Str>.

=head2 crest_url

Crest URL of the team, of type C<Str>.

=head2 position

Team's position in table, of type C<Int>.

=head2 games_played

Number of games the team has played, of type C<Int>.

=head2 goals_for

Number of goals the team has scored, of type C<Int>.

=head2 goals_against

Number of goals the team has conceded, of type C<Int>.

=head2 goal_difference

Goal difference of the team, of type C<Int>.

=head2 wins

Number of the team's wins, of type C<Int>.

=head2 draws

Number of the team's draws, of type C<Int>.

=head2 losses

Number of the team's losses, of type C<Int>.

=head2 points

Points of the team, of type C<Int>.

=head2 home

Contains the home stats. An instance of C<WebService::FootballData::League::Table::Row::Home>.

Has the following attributes:

=item goals_for

=item goals_against

=item wins

=item draws

=item losses

=head2 away

Contains the away stats. An instance of C<WebService::FootballData::League::Table::Row::Away>.

Has the following attributes:

=item goals_for

=item goals_against

=item wins

=item draws

=item losses

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