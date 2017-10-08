use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Report', 'Finance::GDAX::API::Report useable';
use Finance::GDAX::API::Report;

ok my $report = Finance::GDAX::API::Report.new, 'Instantiate';

can-ok($report, 'type');
can-ok($report, 'start-date');
can-ok($report, 'end-date');
can-ok($report, 'product-id');
can-ok($report, 'account-id');
can-ok($report, 'format');
can-ok($report, 'email');
can-ok($report, 'report-id');
can-ok($report, 'get');
can-ok($report, 'create');

ok ($report.start-date = DateTime.new('2017-06-01T00:00:00.000Z')), 'can set start_date';
ok ($report.end-date   = DateTime.new('2017-06-15T00:00:00.000Z')), 'can set end_date';

is $report.format, 'pdf', 'Default format is good';
dies-ok { $report.format = 'badformat' }, 'format dies on bad value';
ok ($report.format = 'csv'), 'format sets on good value';

dies-ok { $report.type = 'badvalue' }, 'bad type dies ok';
ok ($report.type = 'fills'), 'type sets ok to fills';

dies-ok { $report.create }, 'dies good when type is fills and no product-id';
ok ($report.type = 'account'), 'type sets ok to account';
dies-ok { $report.create }, 'dies good when type is account and no account-id';
ok ($report.product-id = 'BTC-USD'), 'product ID can be set';

if $do-online-tests {
     $report.debug = True; # Make sure this is set to 1 or you'll use live data

     $report.type = 'fills';
     ok (my $result = $report.create), 'can create fills BTC-USD report';
     is $result.WHAT, (Hash), 'create returns hash';
     ok $result<id>.defined, 'got a report id back';
     note "ERROR: " ~ $report.error if $report.error;

     $report = Finance::GDAX::API::Report.new;
     ok ($report.report-id = $result<id>), 'can assign report_id for getting';
     ok (my $get_result = $report.get), 'Can get report status that was created';
     is $get_result.WHAT, (Hash), 'get returns hash';
}

done-testing;
