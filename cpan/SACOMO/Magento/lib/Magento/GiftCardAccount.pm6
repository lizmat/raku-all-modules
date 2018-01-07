use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::GiftCardAccount;

proto sub carts-giftCards(|) is export {*}
# GET    /V1/carts/:quoteId/giftCards
our multi carts-giftCards(
    Hash $config,
    Int  :$quote_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$quote_id/giftCards";
}

# PUT    /V1/carts/:cartId/giftCards
our multi carts-giftCards(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/$cart_id/giftCards",
        content => to-json $data;
}

# DELETE /V1/carts/:quoteId/giftCards/:giftCardCode
our sub carts-giftCards-delete(
    Hash $config,
    Int  :$quote_id!,
    Str  :$gift_card_code!
) {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "carts/$quote_id/giftCards/$gift_card_code";
}

# POST   /V1/carts/mine/giftCards
our sub carts-mine-giftCards(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/giftCards",
        content => to-json $data;
}

# POST   /V1/carts/guest-carts/:cartId/giftCards
our sub carts-guest-carts-giftCards(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/guest-carts/$cart_id/giftCards",
        content => to-json $data;
}

# GET    /V1/carts/guest-carts/:cartId/checkGiftCard/:giftCardCode
our sub carts-guest-carts-checkGiftCard(
    Hash $config,
    Int  :$cart_id!,
    Str  :$gift_card_code!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/guest-carts/$cart_id/checkGiftCard/$gift_card_code";
}

# GET    /V1/carts/mine/checkGiftCard/:giftCardCode
our sub carts-mine-checkGiftCard(
    Hash $config,
    Str  :$gift_card_code!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/checkGiftCard/$gift_card_code";
}

