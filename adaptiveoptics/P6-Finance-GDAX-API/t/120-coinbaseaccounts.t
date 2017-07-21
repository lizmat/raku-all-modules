use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::CoinbaseAccount', 'Finance::GDAX::API::CoinbaseAccount useable';
use Finance::GDAX::API::CoinbaseAccount;

ok (my $coinbase_acct = Finance::GDAX::API::CoinbaseAccount.new), 'Instiatiate';

can-ok($coinbase_acct, 'get');

if $do-online-tests {
     $coinbase_acct.debug = True; # Make sure this is set to 1 or you'll use live data

     ok (my $result = $coinbase_acct.get), 'can get all funding';
     is $result.WHAT, (Array), 'get returns array';
}

done-testing;
