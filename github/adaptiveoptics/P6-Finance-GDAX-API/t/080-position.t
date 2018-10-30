use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Position', 'Finance::GDAX::API::Position useable';
use Finance::GDAX::API::Position;

ok my $position = Finance::GDAX::API::Position.new;

can-ok($position, 'repay-only');
can-ok($position, 'get');
can-ok($position, 'close');

dies-ok { $position.repay_only = 'badtype' }, 'repay-only dies good on bad values';
ok ($position.repay-only = True), 'repay-only can be set to known good value';
    
if $do-online-tests {

    $position.debug = True; # Make sure this is set to 1 or you'll use live data

     ok (my $result = $position.get), 'can get overview of profile';
     is $result.WHAT, (Hash), 'get returns a hash';
     ok $result<accounts>.defined, 'Hash returns accounts key';
     ok $result<accounts><USD>.defined, 'Hash returns USD account key';
     ok $result<accounts><USD><id>.defined, 'Hash returns USD account id key';
}

done-testing;

