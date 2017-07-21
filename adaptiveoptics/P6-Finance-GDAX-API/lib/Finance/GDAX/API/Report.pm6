use v6;
use Finance::GDAX::API::TypeConstraints;
use Finance::GDAX::API;

class Finance::GDAX::API::Report does Finance::GDAX::API
{
    has ReportType   $.type       is rw;
    has DateTime     $.start-date is rw;
    has DateTime     $.end-date   is rw;
    has              $.product-id is rw;
    has              $.account-id is rw;
    has ReportFormat $.format     is rw = 'pdf';
    has              $.email      is rw;

    # For checking with "get" method
    has $.report-id is rw;

    method get(:$!report-id = $.report-id) {
	die 'get report requires a report-id' unless $.report-id;
	$.path   = 'reports/$report_id';
	$.method = 'GET';
	return self.send;
    }

    method create() {
	die 'report type is required'       unless $.type;
	die 'report start date is required' unless $.start-date;
	die 'report end date is required'   unless $.end-date;
	my %body = ( type       => $.type,
		     start_date => $.start-date.Str,
		     end_date   => $.end-date.Str,
		     format     => $.format );
	if ($.type eq 'fills') {
	    die 'product-id is required for fills report' unless $.product-id;
            %body<product_id> = $.product-id;
	}
	if ($.type eq 'account') {
	    die 'account-id is required for account report' unless $.account-id;
            %body<account_id> = $.account-id;
	}
	%body<email> = $.email if $.email;
	$.method = 'POST';
	$.body   = %body;
	$.path   = 'reports';
	return self.send;
    }
}

=begin pod

=head1 NAME

Finance::GDAX::API::Report - Generate GDAX Reports

=head1 SYNOPSIS

  =begin code :skip-test
  use Finance::GDAX::API::Report;

  $report = Finance::GDAX::API::Report.new(
            start_date => DateTime.new('2017-06-01T00:00:00.000Z'),
            end_date   => DateTime.new('2017-06-15T00:00:00.000Z'),
            type       => 'fills');

  $report.product-id = 'BTC-USD';
  %result = $report.create;

  $report_id = %result<id>;

  # After you create the report, you check if it's generated yet

  $report = Finance::GDAX::API::Report.new;
  %result = $report.get(report-id => $report_id);
  
  if (%result<status> eq 'ready') {
     qqx{ wget %result<file_url> };
  }
  =end code

=head2 DESCRIPTION

Generating reports at GDAX is a 2-step process. First you must tell
GDAX to create the report, then you must check to see if the report is
ready for download at a URL. You can also specify and email address to
have it mailed.

Reports can be "fills" or "account". If fills, then a product-id is
needed. If account then an account-id is needed.

The format can be "pdf" or "csv" and defaults to "pdf".

=head1 ATTRIBUTES

=head2 type

Report type, either "fills" or "account". This must be set before
calling the "create" method.

=head2 start-date DateTime

Start of datetime range of report as a DateTime object (required for
create)

=head2 end-date DateTime

End of datetime range of report as a DateTime object (required for
create)

=head2 product-id

The product ID, eg 'BTC-USD'. Required for fills type.

=head2 account-id

The account ID. Required for account type.

=head2 format (default: "pdf")

Output format of report, either "pdf" or "csv"

=head2 email

Email address to send the report to (optional)

=head2 report-id

This is used for the "get" method only, and can also be passed as a
parameter to the "get" method.

It is the report id as returned by the "create" method.

=head1 METHODS

=head2 create

Creates the GDAX report based upon the attributes set and returns a
hash result as documented in the API:

  {
    "id": "0428b97b-bec1-429e-a94c-59232926778d",
    "type": "fills",
    "status": "pending",
    "created_at": "2015-01-06T10:34:47.000Z",
    "completed_at": undefined,
    "expires_at": "2015-01-13T10:35:47.000Z",
    "file_url": undefined,
    "params": {
        "start_date": "2014-11-01T00:00:00.000Z",
        "end_date": "2014-11-30T23:59:59.000Z"
    }
  }

=head2 get (:$report_id)

Returns a hash representing the status of the report created with the
"create" method.

The parameter $report_id is optional - if it is passed to the method,
it overrides the object's report_id attribute.

The result when first creating the report might look like this:

  {
    "id": "0428b97b-bec1-429e-a94c-59232926778d",
    "type": "fills",
    "status": "creating",
    "created_at": "2015-01-06T10:34:47.000Z",
    "completed_at": undefined,
    "expires_at": "2015-01-13T10:35:47.000Z",
    "file_url": undefined,
    "params": {
        "start_date": "2014-11-01T00:00:00.000Z",
        "end_date": "2014-11-30T23:59:59.000Z"
    }
  }

While the result when GDAX finishes generating the report might look
like this:

  {
    "id": "0428b97b-bec1-429e-a94c-59232926778d",
    "type": "fills",
    "status": "ready",
    "created_at": "2015-01-06T10:34:47.000Z",
    "completed_at": "2015-01-06T10:35:47.000Z",
    "expires_at": "2015-01-13T10:35:47.000Z",
    "file_url": "https://example.com/0428b97b.../fills.pdf",
    "params": {
        "start_date": "2014-11-01T00:00:00.000Z",
        "end_date": "2014-11-30T23:59:59.000Z"
    }
  }

=head1 AUTHOR

Mark Rushing <mark@orbislumen.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2017 by Home Grown Systems, SPC.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=end pod
