use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::GiftRegistry;

# POST   /V1/giftregistry/mine/estimate-shipping-methods
our sub giftregistry-mine-estimate-shipping-methods(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "giftregistry/mine/estimate-shipping-methods",
        content => to-json $data;
}

# POST   /V1/guest-giftregistry/:cartId/estimate-shipping-methods
our sub guest-giftregistry-estimate-shipping-methods(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-giftregistry/$cart_id/estimate-shipping-methods",
        content => to-json $data;
}

