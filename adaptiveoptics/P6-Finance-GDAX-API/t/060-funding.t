use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Funding', 'Finance::GDAX::API::Funding useable';
use Finance::GDAX::API::Funding;

ok my $funding = Finance::GDAX::API::Funding.new;

can-ok($funding, 'get');
can-ok($funding, 'repay');
can-ok($funding, 'status');
can-ok($funding, 'amount');
can-ok($funding, 'currency');

dies-ok { $funding.status = 'badstatus' }, 'status dies good on bad values';
dies-ok { $funding.amount = -250.00 },     'amount dies good on bad value';
ok ($funding.status = 'settled'), 'status can be set to known good value';

if $do-online-tests {

    $funding.debug = True ; # Make sure this is set to 1 or you'll use live data

    my $result = $funding.get;
    is $result.WHAT, (Array), 'can get all funding';
    ok $helper.check-error($funding), 'can get all funding had no error';
}

done-testing;

