use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Currency', 'Finance::GDAX::API::Currency useable';
use Finance::GDAX::API::Currency;

ok my $currency = Finance::GDAX::API::Currency.new, 'Instantiated';

can-ok($currency, 'list');
    
if $do-online-tests {
     $currency.debug = True; # Make sure this is set to 1 or you'll use live data

     ok (my $result = $currency.list), 'can get currency list';
     is $result.WHAT, (Array), 'get returns array';
}

done-testing;
