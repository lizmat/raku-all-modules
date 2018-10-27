use v6;
use Finance::GDAX::API;

class Finance::GDAX::API::UserAccount does Finance::GDAX::API
{
    method trailing-volume() {
	$.method = 'GET';
	$.path   = 'users/self/trailing-volume';
	return self.send;
    }
}

=begin pod

=head1 NAME

Finance::GDAX::API::UserAccount - Account Info

=head1 SYNOPSIS

  =begin code :skip-test
  use Finance::GDAX::API::UserAccount;

  $account = Finance::GDAX::API::UserAccount.new;

  # List of trailing volume
  @trailing = $account.trailing-volume;
  =end code

=head2 DESCRIPTION

Returns a list of hashes, representing the Trailing Volume on the account.

=head1 METHODS

=head2 trailing_volume

From the GDAX API:

This request will return your 30-day trailing volume for all
products. This is a cached value that's calculated every day at
midnight UTC.

  [
    {
        "product_id": "BTC-USD",
        "exchange_volume": "11800.00000000",
        "volume": "100.00000000",
        "recorded_at": "1973-11-29T00:05:01.123456Z"
    },
    {
        "product_id": "LTC-USD",
        "exchange_volume": "51010.04100000",
        "volume": "2010.04100000",
        "recorded_at": "1973-11-29T00:05:02.123456Z"
    }
  ]

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod
