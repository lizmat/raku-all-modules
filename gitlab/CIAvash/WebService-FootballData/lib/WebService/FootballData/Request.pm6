use WebService::FootballData::Facade::UserAgent;
use WebService::FootballData::Role::UserAgent;
use WebService::FootballData::Role::Request;
use URI::Escape;

unit class WebService::FootballData::Request does WebService::FootballData::Role::Request;

has Str $.api_key;
has Str $.content;
has Str $.base_url = 'http://api.football-data.org/v1/';

has WebService::FootballData::Role::UserAgent $.ua = WebService::FootballData::Facade::UserAgent.new;

method get (Str $url is copy, :%params) {
    # Prepend the base url if url is not absolute
    $url = $!base_url ~ uri-escape($url) unless $url ~~ /^https? '://'/;

    if %params {
        # Encode and join parameters and then append them to url
        $url ~= '?' ~ %params.kv.map(&uri-escape).hash.sort.map(*.kv.join: '=').join: '&';
    }

    # Set header fields
    my %headers = (:X-Auth-Token($!api_key), :X-Response-Control($!content)).grep: *.value.defined;

    my Str $response = $!ua.get: $url, |%headers;

    self!from_json: $response;
}

=begin pod

=head1 NAME

WebService::FootballData::Request - Class for making HTTP requests on football-data.org

=head1 SYNOPSIS

=begin code

use WebService::FootballData::Request;

my $request = WebService::FootballData::Request.new(
    api_key => '12345',
    content => 'compressed',
    base_url => 'http://api.football-data.org/v1/'
);

my @leagues = $request.get: 'soccerseasons';

=end code

=head1 DESCRIPTION

Class that makes it easy to do HTTP requests on football-data.org.

=head1 ATTRIBUTES

=head2 api_key

API key provided by football-data.org, of type C<Str>.

=head2 content

Response's shape, of type C<Str>. As specified by football-data.org.

=head2 base_url

Base URL used for making HTTP requests, of type C<Str>.

=head2 ua

A user agent object that does the L<WebService::FootballData::Role::UserAgent> role.
Defaults to an instance of L<WebService::FootballData::Facade::UserAgent>.

=head1 METHODS

=head2 get

    $request.get: 'teams/65/fixtures';
    $request.get: 'teams/65/fixtures', params => :season(2014);

Takes:

=item A resource or an absolute URL, of type C<Str>.

=item Named argument C<params>, of type C<Hash>.

Returns the JSON response as Perl 6 data structure.

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