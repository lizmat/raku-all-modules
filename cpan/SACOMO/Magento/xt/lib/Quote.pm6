use v6;
use Base64;

unit module Quote;

our sub carts {
    %();
}

our sub carts-billing-address() {
    address => %{
            firstname       => 'Camelia',
            lastname        => 'Butterfly',
            postcode        => '90210',
            city            => 'Beverly Hills',
            street          => ['Zoe Ave'],
            regionId        => 12,
            countryId       => 'US',
            telephone       => '555-555-5555'
    }
}

our sub carts-coupons {
    %();
}

our sub carts-estimate-shipping-methods {
    address => %{
        firstname       => 'Camelia',
        lastname        => 'Butterfly',
        email           => 'p6magento@fakeemail.com',
        postcode        => '90210',
        city            => 'Beverly Hills',
        street          => ['Zoe Ave'],
        regionId        => 12,
        countryId       => 'US',
        telephone       => '555-555-5555'
    }
}

our sub carts-estimate-shipping-methods-by-address-id {
    %();
}

our sub carts-items(
    Str :$quote_id
) {
    cartItem  => %{
        sku => 'P6-TEST-DELETE',
        qty => 1,
        quoteId => "$quote_id"
    }
}

our sub carts-items-update(
    Str :$quote_id
) {
    cartItem  => %{
        sku => 'P6-TEST-DELETE',
        qty => 5,
        quoteId => "$quote_id"
    }
}

our sub carts-mine {
    %();
}

our sub carts-mine-billing-address {
    %();
}

our sub carts-mine-collect-totals {
    %();
}

our sub carts-mine-coupons {
    %();
}

our sub carts-mine-estimate-shipping-methods {
}

our sub carts-mine-estimate-shipping-methods-by-address-id {
    %();
}

our sub carts-mine-items(
    :$cart_id
) {
    cartItem  => %{
        sku => 'P6-TEST-DELETE',
        qty => 5,
        quoteId => "$cart_id"
    }
}

our sub carts-mine-items-update(
    :$cart_id 
) {
    cartItem  => %{
        sku => 'P6-TEST-DELETE',
        qty => 7,
        quoteId => "$cart_id"
    }
}

our sub carts-mine-order {
    %();
}

our sub carts-mine-selected-payment-method {
    %();
}

our sub carts-order {
    %();
}

our sub carts-selected-payment-method {
    %();
}

our sub customers-carts {
    %();
}

our sub guest-carts {
    %();
}

our sub guest-carts-billing-address {
    %();
}

our sub guest-carts-collect-totals {
    %();
}

our sub guest-carts-coupons {
    %();
}

our sub guest-carts-estimate-shipping-methods {
    %();
}

our sub guest-carts-items(
    :$cart_id 
) {
    cartItem  => %{
        sku => 'P6-TEST-DELETE',
        qty => 5,
        quoteId => "$cart_id"
    }
}

our sub guest-carts-items-update(
    :$cart_id 
) {
    cartItem  => %{
        sku => 'P6-TEST-DELETE',
        qty => 7,
        quoteId => "$cart_id"
    }
}

our sub guest-carts-order {
    %();
}

our sub guest-carts-selected-payment-method {
    %();
}

