use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Fill', 'Finance::GDAX::API::Fill useable';
use Finance::GDAX::API::Fill;

ok my $fill = Finance::GDAX::API::Fill.new;

can-ok($fill, 'get');
can-ok($fill, 'order-id');
can-ok($fill, 'product-id');

if $do-online-tests {

    $fill.debug = True; # Make sure this is set to 1 or you'll use live data

    my $result = $fill.get;
    ok $helper.check-error($fill), 'get fill had no error';
    is $result.WHAT, (Array), 'get fill';
}

done-testing;

