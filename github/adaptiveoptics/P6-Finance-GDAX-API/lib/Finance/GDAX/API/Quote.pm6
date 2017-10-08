use v6;
use Finance::GDAX::API;

class Finance::GDAX::API::Quote does Finance::GDAX::API
{
    has $.product-id is rw = 'BTC-USD';

    method get(:$!product-id = $.product-id) {
	die 'quotes need a product-id' unless $.product-id;
	$.path   = 'products';
	$.method = 'GET';
	self.add-to-url($.product-id);
	self.add-to-url('ticker');
	return self.send;
    }
}

=begin pod

=head1 NAME

Finance::GDAX::API::Quote - Get a quote from the GDAX

=head1 SYNOPSIS

  =begin code
  use Finanace::GDAX::API::Quote;
  %quote = Finance::GDAX::API::Quote->new(product-id => 'BTC-USD')->get;
  =end code

=head1 DESCRIPTION

Gets a quote from the GDAX for the specified "product". These quotes
do not require GDAX API keys, but they suggesting keeping traffic low.

More detailed information can be retrieve about products and history
using API keys with other classes like Finance::GDAX::API::Product

Currently, the supported products are:

  BTC-USD
  BTC-GBP
  BTC-EUR
  ETH-BTC
  ETH-USD
  LTC-BTC
  LTC-USD
  ETH-EUR

These are not hard-coded, but the default is BTC-USD, so if any are
added by GDAX in the future, it should work find if you can find the
product code.

Quote is returned as a hashref with the (currently) following keys:

  trade_id
  price
  size
  bid
  ask
  volume
  time

=head1 ATTRIBUTES

=head2 product (default: "BTC-USD")

The product code for which to return the quote.

=head1 METHODS

=head2 get (:$product-id)

Returns a quote for the desired product.

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod
