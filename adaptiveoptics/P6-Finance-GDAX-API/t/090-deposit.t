use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Deposit', 'Finance::GDAX::API::Deposit useable';
use Finance::GDAX::API::Deposit;

my $deposit;
dies-ok {$deposit = Finance::GDAX::API::Deposit.new}, 'Instantiation dies without currency and amount';
ok ($deposit = Finance::GDAX::API::Deposit.new(:currency('USD'), :amount(250))), 'New ok with good vals';

can-ok($deposit, 'payment-method-id');
can-ok($deposit, 'coinbase-account-id');
can-ok($deposit, 'amount');
can-ok($deposit, 'currency');

dies-ok { $deposit.amount = -250.00 }, 'amount dies good on bad value';
ok ($deposit.amount = 250.00), 'amount can be set to known good value';
dies-ok { $deposit.from-payment }, 'from-payment dies correctly if not all attributes set';
dies-ok { $deposit.from-coinbase }, 'from-coinbase dies correctly if not all attributes set';
    
if $do-online-tests {
     $deposit.debug = True; # Make sure this is set to 1 or you'll use live data

     #ok (my $result = $deposit->initiate, 'can get all funding');
     #is (ref $result, 'ARRAY', 'get returns array');
}

done-testing;
