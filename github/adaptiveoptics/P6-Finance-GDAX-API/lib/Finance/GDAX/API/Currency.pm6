use v6;
use Finance::GDAX::API;

class Finance::GDAX::API::Currency does Finance::GDAX::API
{
    method list() {
	$.method = 'GET';
	$.path   = 'currencies';
	return self.send;
    }
}

=begin pod

=head1 NAME

Finance::GDAX::API::Currency - Currencies

=head1 SYNOPSIS

  =begin code :skip-test
  use Finance::GDAX::API::Currency;

  $currency = Finance::GDAX::API::Currency.new;

  # List all currencies
  @currencies = $currency.list;
  =end code

=head2 DESCRIPTION

Work with GDAX currencies.

=head1 METHODS

=head2 list

From the GDAX API:

Returns an array of hashes of known currencies.

Currency Codes

Currency codes will conform to the ISO 4217 standard where
possible. Currencies which have or had no representation in ISO 4217
may use a custom code.

  [{
    "id": "BTC",
    "name": "Bitcoin",
    "min_size": "0.00000001"
  }, {
    "id": "USD",
    "name": "United States Dollar",
    "min_size": "0.01000000"
  }]

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod
