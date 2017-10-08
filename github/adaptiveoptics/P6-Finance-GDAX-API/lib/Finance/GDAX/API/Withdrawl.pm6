use v6;
use Finance::GDAX::API::TypeConstraints;
use Finance::GDAX::API;

class Finance::GDAX::API::Withdrawl does Finance::GDAX::API
{
    has             $.payment-method-id   is rw;
    has             $.coinbase-account-id is rw;
    has             $.crypto-address      is rw;
    has PositiveNum $.amount              is rw is required;
    has             $.currency            is rw is required;

    method to-payment(:$!payment-method-id = $.payment-method-id) {
	fail 'withdrawl to payments requires a payment-method-id' unless $.payment-method-id;
	$.path   = 'withdrawls/payment-method';
	$.method = 'POST';
	$.body   = { amount            => $.amount,
		     currency          => $.currency,
		     payment_method_id => $.payment-method-id };
	
	return self.send;
    }

    method to-coinbase(:$!coinbase-account-id = $.coinbase-account-id) {
	fail 'withdrawl to coinbase requires coinbase-account-id' unless $.coinbase-account-id;
	$.path   = 'withdrawls/coinbase-account';
	$.method = 'POST';
	$.body   = { amount              => $.amount,
		     currency            => $.currency,
		     coinbase_account_id => $.coinbase-account-id };

	return self.send;
    }

    method to-crypto(:$!crypto-address = $.crypto-address) {
	fail 'withdrawl to crypto requires crypto-address' unless $.crypto-address;
	$.path   = 'withdrawls/crypto';
	$.method = 'POST';
	$.body   = { amount         => $.amount,
		     currency       => $.currency,
		     crypto_address => $.crypto-address };
	
	return self.send;
    }
}

=begin pod

=head1 NAME

Finance::GDAX::API::Withdrawl - Withdraw funds to a Payment Method or
Coinbase

=head1 SYNOPSIS

  =begin code :skip-test
  use Finance::GDAX::API::Withdraw;

  $withdraw = Finance::GDAX::API::Withdraw.(
              currency => 'USD',
              amount   => 250.00);

  $withdraw.payment-method-id = 'kwji-wefwe-ewrgeurg-wef';
  %response = $withdraw.to-payment;

  # Or, to a Coinbase account
  $withdraw.coinbase-account-id = 'woifhe-i234h-fwikn-wfihwe';
  %response = $withdraw.to-coinbase;

  # Or, to a Crypto address
  %withdraw->crypto-address(:crypto-address('1PtbhinXWpKZjD7CXfFR7kG8RF8vJTMCxA'));
  =end code

=head2 DESCRIPTION

Used to transfer funds out of your GDAX account, either to a
predefined Payment Method or your Coinbase account.

All methods require the same two attributes: "amount" and "currency"
to be set, along with their corresponding payment or coinbase account
id's.

=head1 ATTRIBUTES

=head2 payment-method-id

ID of the payment method.

=head2 coinbase-account-id

ID of the coinbase account.

=head2 crypto-address

Withdraw funds to a crypto address.

=head2 amount

The amount to be withdrawn.

=head2 currency

The currency of the amount -- for example "USD".

=head1 METHODS

=head2 to-payment (:$payment-method-id)

All attributes must be set before calling this method. The return
value is a hash that will describe the result of the payment.

From the current GDAX API documentation, this is how that returned hash is
keyed:

  {
    "id":"593533d2-ff31-46e0-b22e-ca754147a96a",
    "amount": "10.00",
    "currency": "USD",
    "payout_at": "2016-08-20T00:31:09Z"
  }

=head2 to-coinbase (:$coinbase-account-id)

All attributes must be set before calling this method. The return
value is a hash that will describe the result of the funds move.

From the current GDAX API documentation, this is how that returned hash is
keyed:

  {
    "id":"593533d2-ff31-46e0-b22e-ca754147a96a",
    "amount":"10.00",
    "currency": "BTC",
  }

=head2 to-crypto (:$crypto-address)

All attributes must be set before calling this method. The return
value is a hash that will describe the result of the funds move.

From the current GDAX API documentation, this is how that returned hash is
keyed:

  {
    "id":"593533d2-ff31-46e0-b22e-ca754147a96a",
    "amount":"10.00",
    "currency": "BTC",
  }

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod
