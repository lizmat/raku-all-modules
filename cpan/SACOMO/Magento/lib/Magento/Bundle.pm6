use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Bundle;

# GET    /V1/bundle-products/:productSku/children
our sub bundle-products-children(
    Hash $config,
    Str  :$product_sku!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "bundle-products/$product_sku/children";
}

proto sub bundle-products-links(|) is export {*}
# POST   /V1/bundle-products/:sku/links/:optionId
our multi bundle-products-links(
    Hash $config,
    Str  :$sku!,
    Int  :$option_id!,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "bundle-products/$sku/links/$option_id",
        content => to-json $data;
    return $results.Int||$results;
}

# PUT    /V1/bundle-products/:sku/links/:id
our multi bundle-products-links(
    Hash $config,
    Str  :$sku!,
    Int  :$id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "bundle-products/$sku/links/$id",
        content => to-json $data;
}

proto sub bundle-products-options(|) is export {*}
# GET    /V1/bundle-products/:sku/options/:optionId
our multi bundle-products-options(
    Hash $config,
    Str  :$sku!,
    Int  :$option_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "bundle-products/$sku/options/$option_id";
}

# PUT    /V1/bundle-products/options/:optionId
our multi bundle-products-options(
    Hash $config,
    Int  :$option_id!,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "bundle-products/options/$option_id",
        content => to-json $data;
    return $results.Int||$results;
}

# DELETE /V1/bundle-products/:sku/options/:optionId
our sub bundle-products-options-delete(
    Hash $config,
    Str  :$sku!,
    Int  :$option_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "bundle-products/$sku/options/$option_id";
}

# POST   /V1/bundle-products/options/add
our sub bundle-products-options-add(
    Hash $config,
    Hash :$data!
) is export {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "bundle-products/options/add",
        content => to-json $data;
    return $results.Int||$results;
}

# GET    /V1/bundle-products/:sku/options/all
our sub bundle-products-options-all(
    Hash $config,
    Str  :$sku!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "bundle-products/$sku/options/all";
}

# DELETE /V1/bundle-products/:sku/options/:optionId/children/:childSku
our sub bundle-products-options-children-delete(
    Hash $config,
    Str  :$sku!,
    Int  :$option_id!,
    Str  :$child_sku!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "bundle-products/$sku/options/$option_id/children/$child_sku";
}

# GET    /V1/bundle-products/options/types
our sub bundle-products-options-types(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "bundle-products/options/types";
}

