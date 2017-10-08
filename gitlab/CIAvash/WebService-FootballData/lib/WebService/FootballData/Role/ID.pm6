unit role WebService::FootballData::Role::ID[Str $link_name = 'self'];

has %.links is required;

method id returns Int {
    self!extract_id: %!links{$link_name}<href>;
}

method !extract_id (Str $url) returns Int {
    +$url.match: /\d+$/;
}

=begin pod

=head1 NAME

WebService::FootballData::Role::ID - A role for classes that want to extract ID from %.links

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Role::ID;

unit class WebService::FootballData::Team;
also does WebService::FootballData::Role::ID;

=end code

=head1 DESCRIPTION

A parameterized role for classes that want to extract ID from %.links.

    also does WebService::FootballData::Role::ID['team'];

Takes an optional parameter of type C<Str>. It's used to pick the link which the ID will be extracted from.
Defaults to 'self'.

=head1 ATTRIBUTES

=head2 links

A hash containing links provided by football-data.org.

This is a required attribute.

=head1 METHODS

=head2 id

Extracts the ID from C<links> attribute and returns it, of type C<Int>.

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