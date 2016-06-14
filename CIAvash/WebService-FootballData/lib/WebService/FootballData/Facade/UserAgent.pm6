use HTTP::UserAgent;
use WebService::FootballData::Role::UserAgent;

unit class WebService::FootballData::Facade::UserAgent;

also does WebService::FootballData::Role::UserAgent;

has $!ua = HTTP::UserAgent.new: :throw-exceptions;

method get (Str $url, *%headers) returns Str {
    my $response = $!ua.get: $url, |%headers;

    CATCH {
        # Add footballdata_error attribute to the exception and rethrow it
        when X::HTTP::Response {
            my Str $error;
            if .response.content -> $content {
                require JSON::Fast;
                my $data = from-json($content);
                $error = $data<error> if $data<error>:exists;
            }
            ($_ but role { has Str $.footballdata_error = $error }).rethrow;
        }
    }

    if $response.is-success {
        $response.content;
    } else {
        die $response.status-line;
    }
}

=begin pod

=head1 NAME

WebService::FootballData::Facade::UserAgent - A user agent facade

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Facade::UserAgent;

my $ua = WebService::FootballData::Facade::UserAgent.new;

my $leagues_json = $ua.get: 'soccerseasons';

=end code

=head1 DESCRIPTION

A user agent facade.

=head1 METHODS

=head2 get

    $request.get: 'http://api.football-data.org/v1/teams/65/fixtures';
    $request.get: 'http://api.football-data.org/v1/teams/65/fixtures?season=2014', :X-Auth-Token(12345);

Takes:

=item A URL, of type C<Str>.

=item Optional Named arguments as header fields.

Returns the response, of type C<Str>.

=head1 ERRORS

C<HTTP::UserAgent> module is used with exception throwing enabled.
So exceptions will be thrown in case of non-existent resources, out of range values, etc.
See L<http://modules.perl6.org/dist/HTTP::UserAgent>.

When an exception of type C<X::HTTP::Response> is caught, and the response received from football-data.org
contains an error message, an attribute named C<footballdata_error> will be added to the exception
containing that error message.

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