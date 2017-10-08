unit class WebService::FootballData::Team::Player;

has Str $.name;
has Str $.position;
has Int $.number;
has Str $.nationality;
has Date $.birth_date;
has Date $.contract_date;
has Str $.market_value;

method age returns Int {
    return unless $!birth_date;
    my Date $today .= today;
    my Int $age = $today.year - $!birth_date.year;
    my Int $month_diff = $today.month - $!birth_date.month;
    my Int $day_diff = $today.day - $!birth_date.day;
    $age-- if $month_diff < 0 or $month_diff == 0 && $day_diff < 0;
    return $age;
}

=begin pod

=head1 NAME

WebService::FootballData::Team::Player - Class representing a football player

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Team::Player;

my $player = WebService::FootballData::Team::Player.new(
    name => 'Kelechi Iheanacho',
    number => 72,
    birth_date => Date.new('1996-10-03')
);

say $player.age;

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for accessing player data.

C<players> method of L<WebService::FootballData::Team> makes use of player objects.

=head1 ATTRIBUTES

=head2 name

Player's name, of type C<Str>.

=head2 position

Player's position, of type C<Str>.

=head2 number

Player's number, of type C<Int>.

=head2 nationality

Player's nationality, of type C<Str>.

=head2 birth_date

Player's birth date, of type C<Date>.

=head2 contract_date

Date of when player's contract expires, of type C<Date>.

=head2 market_value

Player's market value, of type C<Str>.

=head1 METHODS

=head2 age

    $player.age;

Returns player's age, of type C<Int>.

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