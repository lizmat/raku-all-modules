=begin pod

=head1 NAME

Geo::Coder::OpenCage - Geocode addresses with the OpenCage Geocoder API

=head1 DESCRIPTION

This module provides an interface to the OpenCage geocoding service.

For full details on the API visit L<http://geocoder.opencagedata.com/api.html>.

=head1 SYNOPSIS

    my $geocoder = Geo::Coder::OpenCage.new: api_key => $my_api_key;
    my $result = $geocoder.geocode("Donostia");

=end pod


#| That's the object you'll use to interface with the OpenCage API.
#|
#| It has a required attribute C<api-key>,
#| which you can obtain from http://geocoder.opencagedata.com.
unit class Geo::Coder::OpenCage;
use Geo::Coder::OpenCage::Response;
use HTTP::UserAgent;
use JSON::Unmarshal;
use URI::Escape;

has $.endpoint = "http://api.opencagedata.com/geocode/v1/json";
has $.ua       = HTTP::UserAgent.new;
has $.api-key is required;

method make-request(Str $place-name, %params) returns Str {
    my $url = $.endpoint   ~ "?q=" ~ $place-name;
    $url   ~= "&key="      ~ $.api-key;
    for %params.keys -> $k {
        $url ~= "&$k=" ~ uri-escape(%params{$k})
    }
    my $res = $.ua.get($url);
    return $res.content;
}

#| This method calls to the OpenCage API to obtain geocoding results for
#| C<$place-name>. It returns an object with convenient access methods
#| for all the data that the API returns.
#|
#| You can pass additional hints and requirements to the API through the
#| slurpy C<%params> argument. The validity of these parameters will
#| B<NOT> be verified/enforced to ensure compatibility with potential
#| API changes. Some of the supported arguments include:
#|
#| C<language> – An IETF format language code (such as es for Spanish
#| or pt-BR for Brazilian Portuguese); if this is omitted a code of en
#| (English) will be assumed.
#|
#| C<country> – Provides the geocoder with a hint to the country that
#| the query resides in. This value will help the geocoder but will not
#| restrict the possible results to the supplied country.
#|
#| The country code is a 3 character code as defined by the ISO 3166-1
#| Alpha 3 standard.
#|
#| As a full example:
#|
#|     my $result = $geocoder.geocode(
#|         location => "Псковская улица, Санкт-Петербург, Россия",
#|         language => "ru",
#|         country  => "rus",
#|     );
method geocode(Str $place-name, *%params)
       returns Geo::Coder::OpenCage::Response {
    my $json = self.make-request(uri-escape($place-name), %params);
    return unmarshal $json, Geo::Coder::OpenCage::Response;
}

#| This method, as the name suggests, call the API to obtain information
#| about places existing under the specified coordinates (C<$lat> for
#| lattitude, C<$lng> for longtitude). Additional C<%params> can be
#| passed according to the same rules as in the C<geocode()> method.
method reverse-geocode(Numeric $lat, Numeric $lng, *%params)
       returns Geo::Coder::OpenCage::Response {
    my $json = self.make-request("$lat+$lng", %params);
    return unmarshal $json, Geo::Coder::OpenCage::Response;
}

=begin pod

=head1 AUTHOR

Tadeusz Sośnierz, C<tadeusz.sosnierz@onet.pl>

=head1 COPYRIGHT AND LICENSE

Copyright 2016 Tadeusz „tadzik” Sośnierz

This project is licensed under the MIT license – see the LICENSE file
for details.

=end pod
