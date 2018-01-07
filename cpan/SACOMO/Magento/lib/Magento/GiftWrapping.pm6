use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::GiftWrapping;

proto sub gift-wrappings(|) is export {*}
# GET    /V1/gift-wrappings/:id
our multi gift-wrappings(
    Hash $config,
    Str  :$id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "gift-wrappings/$id";
}

# POST   /V1/gift-wrappings
our multi gift-wrappings(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "gift-wrappings",
        content => to-json $data;
}

# PUT    /V1/gift-wrappings/:wrappingId
our multi gift-wrappings(
    Hash $config,
    Int  :$wrapping_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "gift-wrappings/$wrapping_id",
        content => to-json $data;
}

# GET    /V1/gift-wrappings
our multi gift-wrappings(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "gift-wrappings";
}

# DELETE /V1/gift-wrappings/:id
our sub gift-wrappings-delete(
    Hash $config,
    Str  :$id!
) {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "gift-wrappings/$id";
}

