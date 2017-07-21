use v6;
use Finance::GDAX::API::TypeConstraints;
use Finance::GDAX::API;

class Finance::GDAX::API::Funding does Finance::GDAX::API
{
    # List funding
    has FundingStatus $.status is rw;

    # Repay funding
    has PositiveNum $.amount   is rw;
    has             $.currency is rw;

    method get(:$!status = $.status) {
	$.path = 'funding';
	self.add-to-url('?status=' ~ $.status) if $.status;
	$.method = 'GET';
	return self.send;
    }

    method repay(:$!amount, :$!currency) {
	
	unless $.amount and $.currency {
	    fail 'repay must specify an amount and currency';
	}
	
	$.method('POST');
	$.body({ amount   => $.amount,
		 currency => $.currency });
	
	$.path('funding/repay');
	return self.send;
    }
}

=begin pod

=head1 NAME

Finance::GDAX::API::Funding - List GDAX margin funding records

=head1 SYNOPSIS

  =begin code :skip-test
  use Finance::GDAX::API::Funding;

  $funding = Finance::GDAX::API::Funding.new;
  @records = $funding.get;

  # To limit records based on current status
  $funding.status = 'settled';
  @records = $funding.get;

  # To repay some margin funding
  $funding->repay(amount   => 255.45,
		  currency => 'USD' );
  =end code

=head2 DESCRIPTION

Returns an array of funding records from GDAX for orders placed with a
margin profile. Also repays margin funding.

From the GDAX API:

Every order placed with a margin profile that draws funding will
create a funding record.

  [
  {
    "id": "b93d26cd-7193-4c8d-bfcc-446b2fe18f71",
    "order_id": "b93d26cd-7193-4c8d-bfcc-446b2fe18f71",
    "profile_id": "d881e5a6-58eb-47cd-b8e2-8d9f2e3ec6f6",
    "amount": "1057.6519956381537500",
    "status": "settled",
    "created_at": "2017-03-17T23:46:16.663397Z",
    "currency": "USD",
    "repaid_amount": "1057.6519956381537500",
    "default_amount": "0",
    "repaid_default": false
  },
  {
    "id": "280c0a56-f2fa-4d3b-a199-92df76fff5cd",
    "order_id": "280c0a56-f2fa-4d3b-a199-92df76fff5cd",
    "profile_id": "d881e5a6-58eb-47cd-b8e2-8d9f2e3ec6f6",
    "amount": "545.2400000000000000",
    "status": "outstanding",
    "created_at": "2017-03-18T00:34:34.270484Z",
    "currency": "USD",
    "repaid_amount": "532.7580047716682500"
  },
  {
    "id": "d6ec039a-00eb-4bec-a3e1-f5c6a97c4afc",
    "order_id": "d6ec039a-00eb-4bec-a3e1-f5c6a97c4afc",
    "profile_id": "d881e5a6-58eb-47cd-b8e2-8d9f2e3ec6f6",
    "amount": "9.9999999958500000",
    "status": "outstanding",
    "created_at": "2017-03-19T23:16:11.615181Z",
    "currency": "USD",
    "repaid_amount": "0"
  }
  ]

=head1 ATTRIBUTES

=head2 status

Limit the records returned to those records of given status.

Currently the GDAX API states these status must be "outstanding",
"settled" or "rejected".

=head2 amount

The amount to be repaid to margin.

=head2 currency

The currency of the amount -- for example "USD".

You must specify currency and amount when calling the repay method.

=head1 METHODS

=head2 get (:$status?)

Returns an array of funding records from GDAX.

=head2 repay (:$amount!, :$currency!)

Repays the margin, from the oldest funding records first.

Specifying the optional ordered parameters $amount and $currency on
the method call will override any attribute values set for amount and
currency.

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod
