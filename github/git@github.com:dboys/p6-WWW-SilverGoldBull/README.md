[![Build Status](https://api.travis-ci.org/dboys/p6-WWW-SilverGoldBull.png)](https://travis-ci.org/dboys/p6-WWW-SilverGoldBull)

# NAME

WWW::SilverGoldBull - Perl6 client for the Silver Gold Bull(https://silvergoldbull.com/) web service

# VERSION

version 0.01

# SYNOPSIS
    use WWW::SilverGoldBull;
    use WWW::SilverGoldBull::Address;
    use WWW::SilverGoldBull::Item;
    use WWW::SilverGoldBull::Order;
    use WWW::SilverGoldBull::Types;

    my $sgb = WWW::SilverGoldBull.new(key => <API_KEY>);

    #get available currency list
    my $response = $sgb.get-currency-list();
    if ($response.is-success) {
        my $currency-list = $response.data();
    }
    else {
      my $error = $response.error();
    }

    my $billing-addr = WWW::SilverGoldBull::Address.new(
      'city'       => 'Calgary',
      'first_name' => 'John',
      'region'     => 'AB',
      'email'      => 'sales@silvergoldbull.com',
      'last_name'  => 'Smith',
      'postcode'   => 'T2P 5C5',
      'street'     => '888 - 3 ST SW, 10 FLOOR - WEST TOWER',
      'phone'      => '+1 (403) 668 8648',
      'country'    => 'CA'
    );

    my $shipping-addr = WWW::SilverGoldBull::Address.new(
      'city'       => 'Calgary',
      'first_name' => 'John',
      'region'     => 'AB',
      'email'      => 'sales@silvergoldbull.com',
      'last_name'  => 'Smith',
      'postcode'   => 'T2P 5C5',
      'street'     => '888 - 3 ST SW, 10 FLOOR - WEST TOWER',
      'phone'      => '+1 (403) 668 8648',
      'country'    => 'CA'
    );

    my $item = WWW::SilverGoldBull::Item.new(
        'bid_price' => 468.37,
        'qty'       => 1,
        'id'        => '2706',
    );

    my %order-info = (
      "currency"        => "USD",
      "declaration"     => Declaration::TEST,
      "shipping_method" => "1YR_STORAGE",
      "payment_method"  => "paypal",
      "shipping"        => $shipping-addr,
      "billing"         => $billing-addr,
      "items"           => Array.new($item),
    );
    my $order = WWW::SilverGoldBull::Order.new(|%order_info);
    my $response = $sgb.create_order($order);

# OVERVIEW

This is a Perl6 client for the SilverGoldBull API at [Silver Gold Bull API docs](https://silvergoldbull.com/api-docs).

# METHODS

All methods return WWW::SilverGoldBull::Response object.

## get-currency-list

Input: nothing

Result: An available currency list.

## get-payment-method-list

Input: nothing

Result: An available payment method list.

## get-shipping-method-list

Input: nothing

Result: An available shipping method list.

## get-product-list

Input: nothing

Result: An available product list.

## get-product

Input: product id;

Result: Product information.

## get-order

Input: order id;

Result: Order information.

## create-order

Input: WWW::SilverGoldBull::Order object;

Result: Product information.

## create-quote

Input: WWW::SilverGoldBull::Quote object;

Result: Quote information.


# SEE ALSO

- [Silver Gold Bull API docs](https://silvergoldbull.com/api-docs)

# LICENSE AND COPYRIGHT

Copyright (C) 2017 Denis Boyun

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 6 programming language system itself.
