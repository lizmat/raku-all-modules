use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Withdrawl', 'Finance::GDAX::API::Withdrawl useable';
use Finance::GDAX::API::Withdrawl;

my $withdrawl;
dies-ok {$withdrawl = Finance::GDAX::API::Withdrawl.new}, 'Instantiation dies without ammount or currency';;
ok ($withdrawl = Finance::GDAX::API::Withdrawl.new(:amount(100.00), :currency('BTC'))), 'goot instantiation';

can-ok($withdrawl, 'payment-method-id');
can-ok($withdrawl, 'coinbase-account-id');
can-ok($withdrawl, 'crypto-address');
can-ok($withdrawl, 'amount');
can-ok($withdrawl, 'currency');
can-ok($withdrawl, 'to-payment');
can-ok($withdrawl, 'to-coinbase');
can-ok($withdrawl, 'to-crypto');

dies-ok { $withdrawl.amount = -250.00 }, 'amount dies good on bad value';
ok ($withdrawl.amount = 250.00), 'amount can be set to known good value';
dies-ok { $withdrawl.to-payment }, 'to-payment dies correctly if not all attributes set';
dies-ok { $withdrawl.to-coinbase }, 'to-coinbase dies correctly if not all attributes set';
dies-ok { $withdrawl.to-crypto }, 'to-crypto dies correctly if not all attributes set';
    
if $do-online-tests {
     $withdrawl.debug = True; # Make sure this is set to 1 or you'll use live data

     #ok (my $result = $withdrawl->initiate, 'can get all funding');
     #is (ref $result, 'ARRAY', 'get returns array');
}

done-testing;
