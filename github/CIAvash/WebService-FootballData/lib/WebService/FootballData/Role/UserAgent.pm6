unit role WebService::FootballData::Role::UserAgent;

method get { ... }

=begin pod

=head1 NAME

WebService::FootballData::Role::UserAgent - Role UserAgent

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Role::UserAgent;

unit class WebService::FootballData::Facade::UserAgent;
also does WebService::FootballData::Role::UserAgent;

=end code

=head1 DESCRIPTION

Role UserAgent.

=head1 METHODS

=head2 get

Must be implemented by the class that does this role.

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