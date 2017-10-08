use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::PaymentMethod', 'Finance::GDAX::API::PaymentMethod useable';
use Finance::GDAX::API::PaymentMethod;

ok my $pay_method = Finance::GDAX::API::PaymentMethod.new, "instatiated";

can-ok($pay_method, 'get');

if $do-online-tests {
     $pay_method.debug = True; # Make sure this is set to 1 or you'll use live data

     ok (my $result = $pay_method.get), 'can get all funding';
     is $result.WHAT, (List), 'get returns list';
}

done-testing;
