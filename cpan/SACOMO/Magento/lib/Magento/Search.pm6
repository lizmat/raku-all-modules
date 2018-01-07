use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Search;

# GET    /V1/search
our sub search(
    Hash $config,
    Hash :$search_criteria = %{}
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "search?$query_string";
}

