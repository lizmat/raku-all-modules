use v6;
use Test;
use lib <lib t/lib>;
use GDAXTestHelper;

my $helper = GDAXTestHelper.new;
$helper.get-environment;
my Bool $do-online-tests = $helper.do-online-tests;
$helper.set-environment if $do-online-tests;

use-ok 'Finance::GDAX::API::Order', 'Finance::GDAX::API::Order useable';
use Finance::GDAX::API::Order;

ok my $order = Finance::GDAX::API::Order.new;
# Attributes
can-ok($order, 'client_oid');
can-ok($order, 'type');
can-ok($order, 'side');
can-ok($order, 'product_id');
can-ok($order, 'stp');
can-ok($order, 'price');
can-ok($order, 'size');
can-ok($order, 'time_in_force');
can-ok($order, 'cancel_after');
can-ok($order, 'post_only');
can-ok($order, 'funds');
can-ok($order, 'overdraft_enabled');
can-ok($order, 'funding_amount');
# Methods
can-ok($order, 'initiate');
can-ok($order, 'get');
can-ok($order, 'list');
can-ok($order, 'cancel');
can-ok($order, 'cancel_all');
can-ok($order, 'initiate');

dies-ok { $order.price = -45 }, 'bad price dies ok';
dies-ok { $order.size  = 0 }, 'bad size dies ok';
dies-ok { $order.type  = 'BAD' }, 'bad type dies ok';
dies-ok { $order.side  = 'foolish' }, 'bad side dies ok';
dies-ok { $order.stp   = 'xx' }, 'bad stp dies ok';
dies-ok { $order.time_in_force = 'UGH' }, 'bad time_in_force dies ok';
dies-ok { $order.post_only     = 'String' }, 'bad post_only dies ok';

# Set up limit order
ok ($order.side = 'buy'), 'buy side set';
ok ($order.product_id = 'BTC-USD'), 'product_id set';
ok ($order.price = 500.23), 'price set';
ok ($order.size = 0.5), 'size set';

if $do-online-tests {

    $order.debug = True; # Make sure this is set to 1 or you'll use live data

     ok (my $result = $order.initiate), 'limit order initiated';

     # Order Lists
     note "Trying API Keys again...\n";
     $order = Finance::GDAX::API::Order.new;
     my $list = $order.list;
     ok $helper.check-error($order), 'list of orders had no error';
     is $list.WHAT, (Array), 'list of orders';

     $order = Finance::GDAX::API::Order.new;
     $list = $order.list(:status(['active','pending']));
     ok $helper.check-error($order), 'list with multiple status had no error';
     is $list.WHAT, (Array), 'list with multiple status';

     $order = Finance::GDAX::API::Order.new;
     $list = $order.list(:product_id('BTC-USD'));
     ok $helper.check-error($order), 'list of product_id had no error';
     is $list.WHAT, (Array), 'list of product_id';

     $order = Finance::GDAX::API::Order.new;
     $list = $order.list(:status(['active','pending']), :product_id('BTC-USD'));
     ok $helper.check-error($order), 'list with multiple status with product_id had no error';
     is $list.WHAT, (Array), 'list with multiple status with product_id';
}

done-testing;
