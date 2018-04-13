#!/usr/bin/env perl6

use lib 'lib';
use lib 't/lib';
use Koos;
use Test;
use Koos::Test;
use DBIish;
use X::Model::Order;

plan 6;

configure-sqlite;

my $cwd = $*CWD;
$*CWD = 't'.IO;

my Koos $d .=new;
my $db     = DBIish.connect('SQLite', database => 'test.sqlite3');

$d.connect(:$db, :options({
  prefix => 'X',
}));

my ($sth, $scratch);
my $customers = $d.model('Customer');
my $orders    = $d.model('Order');

my $c      = $customers.new-row;
$c.name('customer 1');
$c.contact('joe schmoe');
$c.country('usa');
$c.update;

ok $c.orders.count == 0, 'should have no orders in fresh order table';
for 0..^5 {
  my $o = $orders.new-row;
  $o.set-columns(
    status => ($_ < 3) ?? 'closed' !! 'open',
    customer_id => $c.id,
    order_date => time,
  );
  $o.update;
}

ok $c.orders.count == 5, 'should have 5 orders after inserts';
ok $c.orders.WHAT ~~ X::Model::Order, '.orders should return an X::Model::Order';

ok $c.open_orders.count == 2, '2/5 orders for customer should be open';
ok $c.completed_orders.count == 3, '3/5 orders for customer should be complete';

ok $c.orders.all[0].customer.id == $c.id, 'order.customer.id round trip is correct';

$*CWD = $cwd;
