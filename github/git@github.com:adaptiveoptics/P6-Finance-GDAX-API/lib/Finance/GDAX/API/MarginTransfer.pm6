use v6;
use Finance::GDAX::API::TypeConstraints;
use Finance::GDAX::API;

class Finance::GDAX::API::MarginTransfer does Finance::GDAX::API
{
    has                    $.margin-profile-id is rw is required;
    has MarginTransferType $.type              is rw is required;
    has PositiveNum        $.amount            is rw is required;
    has                    $.currency          is rw is required;

    method initiate {	
	$.path   = 'profiles/margin-transfer';
	$.method = 'POST';
	$.body   = { amount            => $.amount,
		     currency          => $.currency,
		     type              => $.type,
		     margin_profile_id => $.margin-profile-id };

	return self.send;
    }
}

=begin pod

=head1 NAME

Finance::GDAX::API::MarginTransfer - Transfer funds between margin and
standard GDAX profiles

=head1 SYNOPSIS

  =begin code :skip-test
  use Finance::GDAX::API::MarginTransfer;

  $xfer = Finance::GDAX::API::MarginTransfer.new(
          type     => 'withdrawl',
          currency => 'USD',
          amount   => 250.00);

  $xfer.margin_profile_id = 'kwji-wefwe-ewrgeurg-wef';

  %response = $xfer.initiate;
  =end code

=head2 DESCRIPTION

Used to transfer funds between the GDAX standard/default profile and
the margin account. All attributes are required to be set before
calling the "initiate" method.

From the GDAX API:

=over

Transfer funds between your standard/default profile and a margin
profile. A deposit will transfer funds from the default profile into
the margin profile. A withdraw will transfer funds from the margin
profile to the default profile. Withdraws will fail if they would set
your margin ratio below the initial margin ratio requirement.

=back

=head1 ATTRIBUTES

=head2 margin-profile-id

The id of the margin profile you'd like to deposit to or withdraw from.

=head2 type

Currently "deposit" or "withdraw" are valid.

Deposit transfers out from the default profile, into the margin
profile.

Withdraw transfers out of the margin account and into the default
profile.

=head2 amount

The amount to be transferred.

=head2 currency

The currency of the amount -- for example "USD".

=head1 METHODS

=head2 initiate

All attributed must be set before calling this method. The return
value is a hash that will describe the result of the transfer.

From the current GDAX API documentation, this is how that returned hash is
keyed:

  {
  "created_at": "2017-01-25T19:06:23.415126Z",
  "id": "80bc6b74-8b1f-4c60-a089-c61f9810d4ab",
  "user_id": "521c20b3d4ab09621f000011",
  "profile_id": "cda95996-ac59-45a3-a42e-30daeb061867",
  "margin_profile_id": "45fa9e3b-00ba-4631-b907-8a98cbdf21be",
  "type": "deposit",
  "amount": "2",
  "currency": "USD",
  "account_id": "23035fc7-0707-4b59-b0d2-95d0c035f8f5",
  "margin_account_id": "e1d9862c-a259-4e83-96cd-376352a9d24d",
  "margin_product_id": "BTC-USD",
  "status": "completed",
  "nonce": 25
  }

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod
