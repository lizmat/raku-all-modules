use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Quote', 'Finance::GDAX::API::Quote useable';
use Finance::GDAX::API::Quote;

ok my $quote = Finance::GDAX::API::Quote.new, 'Instantiates';
can-ok $quote, 'product-id';
can-ok $quote, 'get';
 
if $do-online-tests {
    $quote.debug = True; # Make sure this is set to 1 or you'll use live data

    ok ($quote.product-id = 'BTC-USD'), 'Can set product-id';
    ok (my %q = $quote.get), 'Can get quote with signed request';
    is %q.WHAT, (Hash), 'Returned quote is a hash';

    $quote = Finance::GDAX::API::Quote.new;
    $quote.signed = False;
    ok (%q = $quote.get(:product-id('BTC-GBP'))), 'Can get quote with unsigned request';
}

done-testing;
