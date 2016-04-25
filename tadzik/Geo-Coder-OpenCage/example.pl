use Geo::Coder::OpenCage;
use Data::Dump;

my $client = Geo::Coder::OpenCage.new:
    api-key => 'Get yours at https://developer.opencagedata.com/';

my $response = $client.geocode("Warsaw", countrycode => "pl");

if $response.status.ok {
    for $response.results -> $place {
        printf "%s\n\tLat:  %s\n\tLong: %s\n",
               $place.formatted, $place.geometry.lat, $place.geometry.lng
    }
}
