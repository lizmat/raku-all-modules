use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Checkout;

subset CartId of Any where Str|Int;

proto sub carts-mine-payment-information(|) is export {*}
# POST   /V1/carts/mine/payment-information
our multi carts-mine-payment-information(
    Hash $config,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/payment-information",
        content => to-json $data;
    return $results.Int||$results;

}

# GET    /V1/carts/mine/payment-information
our multi carts-mine-payment-information(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/payment-information";
}

# POST   /V1/carts/mine/set-payment-information
our sub carts-mine-set-payment-information(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/set-payment-information",
        content => to-json $data;
}

# POST   /V1/carts/mine/shipping-information
our sub carts-mine-shipping-information(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/shipping-information",
        content => to-json $data;
}

# POST   /V1/carts/mine/totals-information
our sub carts-mine-totals-information(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/totals-information",
        content => to-json $data;
}

# POST   /V1/carts/:cartId/shipping-information
our sub carts-shipping-information(
    Hash   $config,
    CartId :$cart_id!,
    Hash   :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/$cart_id/shipping-information",
        content => to-json $data;
}

# POST   /V1/carts/:cartId/totals-information
our sub carts-totals-information(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/$cart_id/totals-information",
        content => to-json $data;
}

proto sub guest-carts-payment-information(|) is export {*}
# POST   /V1/guest-carts/:cartId/payment-information
our multi guest-carts-payment-information(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-carts/$cart_id/payment-information",
        content => to-json $data;
    return $results.Int||$results;
}

# GET    /V1/guest-carts/:cartId/payment-information
our multi guest-carts-payment-information(
    Hash $config,
    Str  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id/payment-information";
}

# POST   /V1/guest-carts/:cartId/set-payment-information
our sub guest-carts-set-payment-information(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-carts/$cart_id/set-payment-information",
        content => to-json $data;
}

# POST   /V1/guest-carts/:cartId/shipping-information
our sub guest-carts-shipping-information(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-carts/$cart_id/shipping-information",
        content => to-json $data;
}

# POST   /V1/guest-carts/:cartId/totals-information
our sub guest-carts-totals-information(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-carts/$cart_id/totals-information",
        content => to-json $data;
}

