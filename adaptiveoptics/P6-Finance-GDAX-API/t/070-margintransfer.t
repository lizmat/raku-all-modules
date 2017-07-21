use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::MarginTransfer', 'Finance::GDAX::API::MarginTransfer useable';
use Finance::GDAX::API::MarginTransfer;

my $xfer;
dies-ok {$xfer = Finance::GDAX::API::MarginTransfer.new}, 'Object needs attributes';
ok ($xfer = Finance::GDAX::API::MarginTransfer.new(
	   :margin-profile-id('dummy-id'),
	   :type('deposit'),
	   :amount(250.00),
	   :currency('USD'))
       ), 'Dummy object created';

can-ok($xfer, 'initiate');

dies-ok { $xfer.type = 'badtype' }, 'type dies good on bad values';
dies-ok { $xfer.amount = -250.00 }, 'amount dies good on bad value';
ok ($xfer.type = 'withdraw'), 'type can be set to known good value';

if $do-online-tests {
     $xfer.debug = True; # Make sure this is set to 1 or you'll use live data

     # Tests here will require creating transactions first... will do later
     #ok (my $result = $xfer->initiate, 'can get all funding');
     #is (ref $result, 'ARRAY', 'get returns array');
}

done-testing;
