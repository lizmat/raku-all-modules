use v6;
use Finance::GDAX::API;

class Finance::GDAX::API::Account does Finance::GDAX::API
{
    has $.id is rw;
    
    method get-all() {
	$.method = 'GET';
	$.path   = 'accounts';
	return self.send.first;
    }

    method get(:$!id = $.id) {
	fail 'Account ID is required' unless $.id;
	$.method = 'GET';
	$.path   = "accounts/$!id";
	return self.send;
    }

    method history(:$!id = $.id) {
	fail 'Account ID is required' unless $.id;
	$.method = 'GET';
	$.path   = "accounts/$!id/ledger";
	return self.send;
    }

    method holds(:$!id = $.id) {
	fail 'Account ID is required' unless $.id;
	$.method = 'GET';
	$.path   = "accounts/$.id/holds";
	return self.send;
    }
}

=begin pod

=head1 NAME

Finance::GDAX::API::Account - Work with GDAX Accounts

=head1 SYNOPSIS

  =begin code :skip-test
  use Finance::GDAX::API::Account;

  $account = Finance::GDAX::API::Account->new(
                            key        => 'wowihefoiwhoihw',
                            secret     => 'woihoip2hf23908hf32hf2h',
                            passphrase => 'woiefhvbno3iurbnv9p4h49h');

  # List all accounts
  
  @accounts = $account.get-all;
  if ($account.error) {
      die 'There was an error ' ~ $account.error;
  }
  for @accounts -> $a {
      print $a<currency> ~ " = " ~ $a<balance>;
  }

  # List a single account
  
  $info = $account.get( id = "wiejfwef-237897-wefhwe-wef");
  say 'Balance is ' ~ $info<balance> ~ $info<currency>;
  =end code

=head1 DESCRIPTION

Creates a GDAX account object to examine accounts.

See Finance::GDAX::API for details on API key requirements that
need to be passed in.

The HTTP response code can be accessed via the "response-code"
attribute, and if the request resulted in a response code greater than
or equal to 400, then the "error" attribute will be set to the error
message returned by the GDAX servers.

=head1 METHODS

=head2 C<get-all>

Returns an array of hashes, with each hash representing account
details. According to the GDAX API, currently these hashes will
contain the following keys and data:

The following represents the data structure from their current API
docs:

  [
      {
          "id": "71452118-efc7-4cc4-8780-a5e22d4baa53",
          "currency": "BTC",
          "balance": "0.0000000000000000",
          "available": "0.0000000000000000",
          "hold": "0.0000000000000000",
          "profile_id": "75da88c5-05bf-4f54-bc85-5c775bd68254"
      },
      {
          "id": "e316cb9a-0808-4fd7-8914-97829c1925de",
          "currency": "USD",
          "balance": "80.2301373066930000",
          "available": "79.2266348066930000",
          "hold": "1.0035025000000000",
          "profile_id": "75da88c5-05bf-4f54-bc85-5c775bd68254"
      }
  ]

  id              Account ID
  balance         total funds in the account
  holds           funds on hold (not available for use)
  available       funds available to withdraw* or trade
  margin_enabled  [margin] true if the account belongs to margin profile
  funded_amount   [margin] amount of outstanding funds currently credited to
                  the account
  default_amount  [margin] amount defaulted on due to not being able to pay
                  back funding

However, this does not appear to be exactly what they are sending now.

=head2 get (:$id)

The get method requires an account id and returns a hash of the
account information. Currently the GDAX API docs say they are:

The following represents the data structure from their current API
docs:

  {
      "id": "a1b2c3d4",
      "balance": "1.100",
      "holds": "0.100",
      "available": "1.00",
      "currency": "USD"
  }

  id 	         Account ID
  balance 	 total funds in the account
  holds 	 funds on hold (not available for use)
  available      funds available to withdraw* or trade
  margin_enabled [margin] true if the account belongs to margin profile
  funded_amount  [margin] amount of outstanding funds currently credited to
                 the account
  default_amount [margin] amount defaulted on due to not being able to pay
                 back funding

=head2 history (:$id)

The history method returns an array of hashes representing the history
of transactions on the specified account_id.

The limit is 100 transactions - no paging has been implemented in this
API, through the GDAX API does support paging apparently.

The following represents the data structure from their current API
docs:

  [
      {
          "id": "100",
          "created_at": "2014-11-07T08:19:27.028459Z",
          "amount": "0.001",
          "balance": "239.669",
          "type": "fee",
          "details": {
              "order_id": "d50ec984-77a8-460a-b958-66f114b0de9b",
              "trade_id": "74",
              "product_id": "BTC-USD"
          }
      }
  ]

In the case of transfers, the dtail may look like this:
  
  details    => {
    transfer_id   => "d50ec984-77a8-460a-b958-66f114b0de9b",
    transfer_type => "deposit",
  },

      

With different "type"'s meaning different "details" -- and those types
are:

  transfer Funds moved to/from Coinbase to GDAX
  match    Funds moved as a result of a trade
  fee      Fee as a result of a trade
  rebate   Fee rebate as per our fee schedule

=head2 holds (:$id)

The holds method returns an array of hashes representing the holds placed on the $account_id account, which happen due to active orders or pending withdrawls.

The following represents the data structure from their current API
docs:

  [
      {
          "id": "82dcd140-c3c7-4507-8de4-2c529cd1a28f",
          "account_id": "e0b3f39a-183d-453e-b754-0c13e5bab0b3",
          "created_at": "2014-11-06T10:34:47.123456Z",
          "updated_at": "2014-11-06T10:40:47.123456Z",
          "amount": "4.23",
          "type": "order",
          "ref": "0a205de4-dd35-4370-a285-fe8fc375a273",
      }
  ]

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod
