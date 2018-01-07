use v6;

use Magento::HTTP;
use Magento::Utils;
use JSON::Fast;

unit module Magento::Quote;

proto sub carts(|) is export {*}
# GET    /V1/carts/:cartId
our multi carts(
    Hash $config,
    Int  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$cart_id";
}

# POST   /V1/carts/
our multi carts(
    Hash $config
) {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/",
        content => '';
    return $results.Int||$results;
}

# PUT    /V1/carts/:cartId
our multi carts(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/$cart_id",
        content => to-json $data;
}

proto sub carts-billing-address(|) is export {*}
# GET    /V1/carts/:cartId/billing-address
our multi carts-billing-address(
    Hash $config,
    Int  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$cart_id/billing-address";
}

# POST   /V1/carts/:cartId/billing-address
our multi carts-billing-address(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/$cart_id/billing-address",
        content => to-json $data;
    return $results.Int||$results;
}

proto sub carts-coupons(|) is export {*}
# GET    /V1/carts/:cartId/coupons
our multi carts-coupons(
    Hash $config,
    Int  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$cart_id/coupons";
}

# PUT    /V1/carts/:cartId/coupons/:couponCode
our multi carts-coupons(
    Hash $config,
    Int  :$cart_id!,
    Str  :$coupon_code!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/$cart_id/coupons/$coupon_code",
        content => '';
}

# DELETE /V1/carts/:cartId/coupons
our sub carts-coupons-delete(
    Hash $config,
    Int  :$cart_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "carts/$cart_id/coupons";
}

# POST   /V1/carts/:cartId/estimate-shipping-methods
our sub carts-estimate-shipping-methods(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/$cart_id/estimate-shipping-methods",
        content => to-json $data;
}

# POST   /V1/carts/:cartId/estimate-shipping-methods-by-address-id
our sub carts-estimate-shipping-methods-by-address-id(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/$cart_id/estimate-shipping-methods-by-address-id",
        content => to-json $data;
}

proto sub carts-items(|) is export {*}
# GET    /V1/carts/:cartId/items
our multi carts-items(
    Hash $config,
    Int  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$cart_id/items";
}

# POST   /V1/carts/:quoteId/items
our multi carts-items(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/$cart_id/items",
        content => to-json $data;
}

# PUT    /V1/carts/:cartId/items/:itemId
our multi carts-items(
    Hash $config,
    Int  :$cart_id!,
    Int  :$item_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/$cart_id/items/$item_id",
        content => to-json $data;
}

# DELETE /V1/carts/:cartId/items/:itemId
our sub carts-items-delete(
    Hash $config,
    Int  :$cart_id!,
    Int  :$item_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "carts/$cart_id/items/$item_id";
}

#proto sub carts-mine(|) is export {*}
# POST   /V1/carts/mine
our sub carts-mine-new(
    Hash $config
) is export {
    my $response = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine",
        content => '';
    return $response.Int||$response;
}

# GET    /V1/carts/mine
our sub carts-mine(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine";
}

# PUT    /V1/carts/mine
our sub carts-mine-update(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/mine",
        content => to-json $data;
}

proto sub carts-mine-billing-address(|) is export {*}
# GET    /V1/carts/mine/billing-address
our multi carts-mine-billing-address(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/billing-address";
}

# POST   /V1/carts/mine/billing-address
our multi carts-mine-billing-address(
    Hash $config,
    Hash :$data!
) {
    my $response = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/billing-address",
        content => to-json $data;
    return $response.Int||$response;
}

# PUT    /V1/carts/mine/collect-totals
our sub carts-mine-collect-totals(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/mine/collect-totals",
        content => to-json $data;
}

proto sub carts-mine-coupons(|) is export {*}
# GET    /V1/carts/mine/coupons
our multi carts-mine-coupons(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/coupons";
}

# PUT    /V1/carts/mine/coupons/:couponCode
our multi carts-mine-coupons(
    Hash $config,
    Str  :$coupon_code!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/mine/coupons/$coupon_code",
        content => to-json $data;
}

# DELETE /V1/carts/mine/coupons
our sub carts-mine-coupons-delete(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "carts/mine/coupons";
}

# POST   /V1/carts/mine/estimate-shipping-methods
our sub carts-mine-estimate-shipping-methods(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/estimate-shipping-methods",
        content => to-json $data;
}

# POST   /V1/carts/mine/estimate-shipping-methods-by-address-id
our sub carts-mine-estimate-shipping-methods-by-address-id(
    Hash $config,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/estimate-shipping-methods-by-address-id",
        content => to-json $data;
}

proto sub carts-mine-items(|) is export {*}
# GET    /V1/carts/mine/items
our multi carts-mine-items(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/items";
}

# POST   /V1/carts/mine/items
our multi carts-mine-items(
    Hash $config,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "carts/mine/items",
        content => to-json $data;
}

# PUT    /V1/carts/mine/items/:itemId
our multi carts-mine-items(
    Hash $config,
    Int  :$item_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/mine/items/$item_id",
        content => to-json $data;
}

# DELETE /V1/carts/mine/items/:itemId
our sub carts-mine-items-delete(
    Hash $config,
    Int  :$item_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "carts/mine/items/$item_id";
}

# PUT    /V1/carts/mine/order
our sub carts-mine-order(
    Hash $config,
    Hash :$data!
) is export {
    my $response = Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/mine/order",
        content => to-json $data;
    return $response.Int||$response;
}

# GET    /V1/carts/mine/payment-methods
our sub carts-mine-payment-methods(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/payment-methods";
}

proto sub carts-mine-selected-payment-method(|) is export {*}
# GET    /V1/carts/mine/selected-payment-method
our multi carts-mine-selected-payment-method(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/selected-payment-method";
}

# PUT    /V1/carts/mine/selected-payment-method
our multi carts-mine-selected-payment-method(
    Hash $config,
    Hash :$data!
) {
    my $response = Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/mine/selected-payment-method",
        content => to-json $data;
    return $response.Int||$response;
}

# GET    /V1/carts/mine/shipping-methods
our sub carts-mine-shipping-methods(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/shipping-methods";
}

# GET    /V1/carts/mine/totals
our sub carts-mine-totals(
    Hash $config
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/mine/totals";
}

# PUT    /V1/carts/:cartId/order
our sub carts-order(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/$cart_id/order",
        content => to-json $data;
}

# GET    /V1/carts/:cartId/payment-methods
our sub carts-payment-methods(
    Hash $config,
    Int  :$cart_id!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$cart_id/payment-methods";
}

# GET    /V1/carts/search
our sub carts-search(
    Hash $config,
    Hash :$search_criteria = %{}
) is export {
    my $query_string = search-criteria-to-query-string $search_criteria;
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/search?$query_string";
}

proto sub carts-selected-payment-method(|) is export {*}
# GET    /V1/carts/:cartId/selected-payment-method
our multi carts-selected-payment-method(
    Hash $config,
    Int  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$cart_id/selected-payment-method";
}

# PUT    /V1/carts/:cartId/selected-payment-method
our multi carts-selected-payment-method(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "carts/$cart_id/selected-payment-method",
        content => to-json $data;
}

# GET    /V1/carts/:cartId/shipping-methods
our sub carts-shipping-methods(
    Hash $config,
    Int  :$cart_id!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$cart_id/shipping-methods";
}

# POST    /V1/carts/:cartId/shipping-address
our sub carts-shipping-address(
    Hash $config,
    Int  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "rest/default/V1/carts/$cart_id/shipping-address",
        content => to-json $data;
}

# GET    /V1/carts/:cartId/totals
our sub carts-totals(
    Hash $config,
    Int  :$cart_id!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "carts/$cart_id/totals";
}

# POST   /V1/customers/:customerId/carts
our sub customers-carts(
    Hash $config,
    Int  :$customer_id!
) is export {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "customers/$customer_id/carts",
        content => '';
    return $results.Int||$results;
}

proto sub guest-carts(|) is export {*}
# GET    /V1/guest-carts/:cartId
our multi guest-carts(
    Hash $config,
    Str  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id";
}

# POST   /V1/guest-carts
our multi guest-carts(
    Hash $config
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-carts",
        content => '';
}

# PUT    /V1/guest-carts/:cartId
our multi guest-carts(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "guest-carts/$cart_id",
        content => to-json $data;
}

proto sub guest-carts-billing-address(|) is export {*}
# GET    /V1/guest-carts/:cartId/billing-address
our multi guest-carts-billing-address(
    Hash $config,
    Str  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id/billing-address";
}

# POST   /V1/guest-carts/:cartId/billing-address
our multi guest-carts-billing-address(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) {
    my $results = Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-carts/$cart_id/billing-address",
        content => to-json $data;
    return $results.Int||$results;
}

# PUT    /V1/guest-carts/:cartId/collect-totals
our sub guest-carts-collect-totals(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "guest-carts/$cart_id/collect-totals",
        content => to-json $data;
}

proto sub guest-carts-coupons(|) is export {*}
# GET    /V1/guest-carts/:cartId/coupons
our multi guest-carts-coupons(
    Hash $config,
    Str  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id/coupons";
}

# PUT    /V1/guest-carts/:cartId/coupons/:couponCode
our multi guest-carts-coupons(
    Hash $config,
    Str  :$cart_id!,
    Str  :$coupon_code!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "guest-carts/$cart_id/coupons/$coupon_code",
        content => '';
}

# DELETE /V1/guest-carts/:cartId/coupons
our sub guest-carts-coupons-delete(
    Hash $config,
    Str  :$cart_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "guest-carts/$cart_id/coupons";
}

# POST   /V1/guest-carts/:cartId/estimate-shipping-methods
our sub guest-carts-estimate-shipping-methods(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) is export {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-carts/$cart_id/estimate-shipping-methods",
        content => to-json $data;
}

proto sub guest-carts-items(|) is export {*}
# GET    /V1/guest-carts/:cartId/items
our multi guest-carts-items(
    Hash $config,
    Str  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id/items";
}

# POST   /V1/guest-carts/:cartId/items
our multi guest-carts-items(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'POST',
        config  => $config,
        uri     => "guest-carts/$cart_id/items",
        content => to-json $data;
}

# PUT    /V1/guest-carts/:cartId/items/:itemId
our multi guest-carts-items(
    Hash $config,
    Str  :$cart_id!,
    Int  :$item_id!,
    Hash :$data!
) {
    Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "guest-carts/$cart_id/items/$item_id",
        content => to-json $data;
}

# DELETE /V1/guest-carts/:cartId/items/:itemId
our sub guest-carts-items-delete(
    Hash $config,
    Str  :$cart_id!,
    Int  :$item_id!
) is export {
    Magento::HTTP::request
        method  => 'DELETE',
        config  => $config,
        uri     => "guest-carts/$cart_id/items/$item_id";
}

# PUT    /V1/guest-carts/:cartId/order
our sub guest-carts-order(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) is export {
    my $response = Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "guest-carts/$cart_id/order",
        content => to-json $data;
    return $response.Int||$response;
}

# GET    /V1/guest-carts/:cartId/payment-methods
our sub guest-carts-payment-methods(
    Hash $config,
    Str  :$cart_id!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id/payment-methods";
}

proto sub guest-carts-selected-payment-method(|) is export {*}
# GET    /V1/guest-carts/:cartId/selected-payment-method
our multi guest-carts-selected-payment-method(
    Hash $config,
    Str  :$cart_id!
) {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id/selected-payment-method";
}

# PUT    /V1/guest-carts/:cartId/selected-payment-method
our multi guest-carts-selected-payment-method(
    Hash $config,
    Str  :$cart_id!,
    Hash :$data!
) {
    my $response = Magento::HTTP::request
        method  => 'PUT',
        config  => $config,
        uri     => "guest-carts/$cart_id/selected-payment-method",
        content => to-json $data;
    return $response.Int||$response;
}

# GET    /V1/guest-carts/:cartId/shipping-methods
our sub guest-carts-shipping-methods(
    Hash $config,
    Str  :$cart_id!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id/shipping-methods";
}

# GET    /V1/guest-carts/:cartId/totals
our sub guest-carts-totals(
    Hash $config,
    Str  :$cart_id!
) is export {
    Magento::HTTP::request
        method  => 'GET',
        config  => $config,
        uri     => "guest-carts/$cart_id/totals";
}

