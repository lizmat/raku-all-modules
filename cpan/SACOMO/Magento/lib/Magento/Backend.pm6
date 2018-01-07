use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Backend;

# GET    /V1/modules
our sub modules(
    Hash $config
) is export {
    my $results = Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "modules";
    return $results.List||$results;
}

