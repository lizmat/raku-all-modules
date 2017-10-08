use WebService::FootballData::Role::HasFixtures;
use WebService::FootballData::Fixtures::Fixture;

unit class WebService::FootballData::Fixtures::Head2Head;

also does WebService::FootballData::Role::HasFixtures;

has Int $.home_team_wins;
has Int $.away_team_wins;
has Int $.draws;
has WebService::FootballData::Fixtures::Fixture $.home_team_last_win_home;
has WebService::FootballData::Fixtures::Fixture $.home_team_last_win;
has WebService::FootballData::Fixtures::Fixture $.away_team_last_win_away;
has WebService::FootballData::Fixtures::Fixture $.away_team_last_win;

=begin pod

=head1 NAME

WebService::FootballData::Fixtures::Head2Head - Class for managing head to head data

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Fixtures::Head2Head;

my $head2head = WebService::FootballData::Fixtures::Head2Head.new(
    home_team_wins => 3,
    away_team_wins => 0
);

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for accessing head to head data.

=head1 ATTRIBUTES

=head2 timeframe_start

Starting date of timeframe, of type C<Date>.

=head2 timeframe_end

Ending date of timeframe, of type C<Date>.

=head2 home_team_wins

Home team wins, of type C<Int>.

=head2 away_team_wins

Away team wins, of type C<Int>.

=head2 draws

Draws, of type C<Int>.

=head2 home_team_last_win_home

Last fixture home team won at home, instance of L<WebService::FootballData::Fixtures::Fixture>.

=head2 home_team_last_win

Last fixture home team won, instance of L<WebService::FootballData::Fixtures::Fixture>.

=head2 away_team_last_win_away

Last fixture away team won away, instance of L<WebService::FootballData::Fixtures::Fixture>.

=head2 away_team_last_win

Last fixture away team won, instance of L<WebService::FootballData::Fixtures::Fixture>.

=head2 fixtures

Fixtures between the 2 teams, Array of L<WebService::FootballData::Fixtures::Fixture> instances.

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