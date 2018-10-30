use v6;
use Finance::GDAX::API;

class Finance::GDAX::API::Time does Finance::GDAX::API
{
    method get {
	$.method = 'GET';
	$.path   = 'time';
	return self.send;
    }
}

=begin pod

=head1 NAME

Finance::GDAX::API::Time - Time

=head1 SYNOPSIS

  =begin code :skip-test
  use Finance::GDAX::API::Time;

  $time = Finance::GDAX::API::Time.new;

  # Get current time
  $time_hash = $time.get;
  =end code

=head2 DESCRIPTION

Gets the time reported by GDAX.

=head1 METHODS

=head2 get

Returns a hash representing the GDAX API server's notion of current
time.

From the GDAX API:

  {
    "iso": "2015-01-07T23:47:25.201Z",
    "epoch": 1420674445.201
  }

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod
