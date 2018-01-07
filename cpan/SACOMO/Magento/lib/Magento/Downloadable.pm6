use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Downloadable;

proto sub products-downloadable-links(|) is export {*}
# GET    /V1/products/:sku/downloadable-links
our multi products-downloadable-links(
    Hash $config,
    Str  :$sku!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/$sku/downloadable-links";
}

# POST   /V1/products/:sku/downloadable-links
our multi products-downloadable-links(
    Hash $config,
    Str  :$sku!,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/$sku/downloadable-links",
        content => to-json $data;
    return $results.Int||$results;
}

# PUT    /V1/products/:sku/downloadable-links/:id
our multi products-downloadable-links(
    Hash $config,
    Str  :$sku!,
    Int  :$id!,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/$sku/downloadable-links/$id",
        content => to-json $data;
    return $results.Int||$results;
}

# DELETE /V1/products/downloadable-links/:id
our sub products-downloadable-links-delete(
    Hash $config,
    Int  :$id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/downloadable-links/$id";
}

proto sub products-downloadable-links-samples(|) is export {*}
# GET    /V1/products/:sku/downloadable-links/samples
our multi products-downloadable-links-samples(
    Hash $config,
    Str  :$sku!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "products/$sku/downloadable-links/samples";
}

# POST   /V1/products/:sku/downloadable-links/samples
our multi products-downloadable-links-samples(
    Hash $config,
    Str  :$sku!,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "products/$sku/downloadable-links/samples",
        content => to-json $data;
    return $results.Int||$results;
}

# PUT    /V1/products/:sku/downloadable-links/samples/:id
our multi products-downloadable-links-samples(
    Hash $config,
    Str  :$sku!,
    Int  :$id!,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "products/$sku/downloadable-links/samples/$id",
        content => to-json $data;
    return $results.Int||$results;
}

# DELETE /V1/products/downloadable-links/samples/:id
our sub products-downloadable-links-samples-delete(
    Hash $config,
    Int  :$id!
) is export {
    my $results = Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "products/downloadable-links/samples/$id";
    return $results.Int||$results;
}

