use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::GiftMessage;

proto sub carts-gift-message(|) is export {*}
# GET    /V1/carts/:cartId/gift-message
our multi carts-gift-message(
    Hash $config,
    Int  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$cart_id/gift-message";
}

# GET    /V1/carts/:cartId/gift-message/:itemId
our multi carts-gift-message(
    Hash $config,
    Int  :$cart_id!,
    Int  :$item_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$cart_id/gift-message/$item_id";
}

# POST   /V1/carts/:cartId/gift-message
our multi carts-gift-message(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/$cart_id/gift-message",
        content => to-json $data;
}

# POST   /V1/carts/:cartId/gift-message/:itemId
our multi carts-gift-message(
    Hash $config,
    Int  :$cart_id!,
    Int  :$item_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/$cart_id/gift-message/$item_id",
        content => to-json $data;
}

proto sub carts-mine-gift-message(|) is export {*}
# GET    /V1/carts/mine/gift-message
our multi carts-mine-gift-message(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/gift-message";
}

# GET    /V1/carts/mine/gift-message/:itemId
our multi carts-mine-gift-message(
    Hash $config,
    Int  :$item_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/gift-message/$item_id";
}

# POST   /V1/carts/mine/gift-message
our multi carts-mine-gift-message(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/gift-message",
        content => to-json $data;
}

# POST   /V1/carts/mine/gift-message/:itemId
our multi carts-mine-gift-message(
    Hash $config,
    Int  :$item_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/gift-message/$item_id",
        content => to-json $data;
}

proto sub guest-carts-gift-message(|) is export {*}
# GET    /V1/guest-carts/:cartId/gift-message
our multi guest-carts-gift-message(
    Hash $config,
    Str  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id/gift-message";
}

# GET    /V1/guest-carts/:cartId/gift-message/:itemId
our multi guest-carts-gift-message(
    Hash $config,
    Str  :$cart_id!,
    Int  :$item_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id/gift-message/$item_id";
}

# POST   /V1/guest-carts/:cartId/gift-message
our multi guest-carts-gift-message(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-carts/$cart_id/gift-message",
        content => to-json $data;
}

# POST   /V1/guest-carts/:cartId/gift-message/:itemId
our multi guest-carts-gift-message(
    Hash $config,
    Str  :$cart_id!,
    Int  :$item_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-carts/$cart_id/gift-message/$item_id",
        content => to-json $data;
}

