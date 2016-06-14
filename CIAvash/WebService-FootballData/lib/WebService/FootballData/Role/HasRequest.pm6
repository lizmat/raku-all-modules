use WebService::FootballData::Role::Request;

unit role WebService::FootballData::Role::HasRequest;

has WebService::FootballData::Role::Request $.request is required;

=begin pod

=head1 NAME

WebService::FootballData::Role::HasRequest - A role for classes that make HTTP requests

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Role::HasRequest;

unit class WebService::FootballData::League;
also does WebService::FootballData::Role::HasRequest;

=end code

=head1 DESCRIPTION

A role for classes that make HTTP requests

=head1 ATTRIBUTES

=head2 request

An object that does the L<WebService::FootballData::Role::Request> role.

This is a required attribute.

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