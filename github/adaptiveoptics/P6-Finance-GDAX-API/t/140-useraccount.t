use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::UserAccount', 'Finance::GDAX::API::UserAccount useable';
use Finance::GDAX::API::UserAccount;

ok my $account = Finance::GDAX::API::UserAccount.new, 'Instantiate';
can-ok($account, 'trailing-volume');
    
if $do-online-tests {
     $account.debug = True; # Make sure this is set to 1 or you'll use live data

     my $result = $account.trailing-volume;
     is $result.WHAT, (Array), 'get returns array';
}

done-testing;
