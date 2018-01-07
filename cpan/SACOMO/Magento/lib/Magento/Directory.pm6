use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Directory;

proto sub directory-countries(|) is export {*}
# GET    /V1/directory/countries
our multi directory-countries(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "directory/countries";
}

# GET    /V1/directory/countries/:countryId
our multi directory-countries(
    Hash $config,
    Str  :$country_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "directory/countries/$country_id";
}

# GET    /V1/directory/currency
our sub directory-currency(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "directory/currency";
}

