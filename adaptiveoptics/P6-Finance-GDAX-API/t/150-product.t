use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Product', 'Finance::GDAX::API::Product useable';
use Finance::GDAX::API::Product;

ok my $product = Finance::GDAX::API::Product.new, 'Instantiate';

can-ok($product, 'product-id');
can-ok($product, 'level');
can-ok($product, 'start');
can-ok($product, 'end');
can-ok($product, 'granularity');
can-ok($product, 'list');
can-ok($product, 'order-book');
can-ok($product, 'ticker');
can-ok($product, 'historic-rates');

dies-ok { $product.level = 8 }, 'dies good on out of range level';
dies-ok { $product.order-book }, 'dies good on order_book without product id';
dies-ok { $product.granularity = 1.5 }, 'dies good on bad granularity';
dies-ok { $product.historic-rates = 'BTC-USD' }, 'dies good without attributes to historic-rates';
ok ($product.granularity = 600), 'can set good granularity to 600';
ok ($product.start = DateTime.new('2017-06-01T00:00:00.000Z')), 'can set start';
ok ($product.end = DateTime.new('2017-06-02T00:00:00.000Z')), 'can set end';

if $do-online-tests {
     $product.debug = True; # Make sure this is set to 1 or you'll use live data

     ok (my $result = $product.list), 'can get product list';
     is $result.WHAT, (Array), 'get returns array';

     $product.product-id = 'BTC-USD';

     ok ($result = $product.order-book), 'can get product order book';
     is $result.WHAT, (Hash), 'order_book returns hash';

     $product = Finance::GDAX::API::Product.new(product-id => 'BTC-USD');
     ok ($result = $product.ticker), 'can get product ticker';
     is $result.WHAT, (Hash), 'ticker returns hash';

     $product = Finance::GDAX::API::Product.new(product-id => 'BTC-USD');
     ok ($result = $product.trades), 'can get product trades';
     is $result.WHAT, (Array), 'trades returns array';

     $product = Finance::GDAX::API::Product.new(product-id => 'BTC-USD');
     $product.granularity = 600;
     $product.start = DateTime.new('2017-06-01T00:00:00.000Z');
     $product.end = DateTime.new('2017-06-02T00:00:00.000Z');
     $result = $product.historic-rates;
     is $result.WHAT, (Array), 'historic rates returns array';
     if $product.error {note $product.error};

     $product = Finance::GDAX::API::Product.new(product-id => 'BTC-USD');
     ok ($result = $product.day-stats), 'can get product day_stats';
     is $result.WHAT, (Hash), 'day_stats returns hash';
}

done-testing;
