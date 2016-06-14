use WebService::FootballData::League::Table::Row;

unit class WebService::FootballData::League::Table;

has %.links;
has Str $.name;
has Int $.matchday;
has WebService::FootballData::League::Table::Row @.rows;

=begin pod

=head1 NAME

WebService::FootballData::League::Table - Class representing a football league table

=head1 SYNOPSIS

=begin code

use WebService::FootballData::League::Table;

my $table = WebService::FootballData::League::Table.new(
    name => '1. Bundesliga 2014/15',
    matchday => 10
);

=end code

=head1 DESCRIPTION

Class for creating objects that provide functionality for accessing league table data.

C<table> method of L<WebService::FootballData::League> makes use of table objects.

=head1 ATTRIBUTES

=head2 links

A hash containing links provided by football-data.org.

=head2 name

Name of the league, of type C<Str>.

=head2 matchday

Matchday of the table, of type C<Int>.

=head2 rows

Table standings: Array of C<WebService::FootballData::League::Table::Row> instances.

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