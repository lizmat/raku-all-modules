#!/usr/bin/env perl6

use lib 'lib';
use lib 't/lib';
use Koos;
use Test;
use Koos::Test;
use DBIish;

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
ok $c.open_orders.count == 2, 'should have 2 open orders after inserts';
$c.orders.close;
ok $c.open_orders.count == 0, 'should have 0 open orders after &X::Model::Order::close';

my $first = $c.orders.all[0];
my $expc  = $c.orders.count+1;
my $copy  = $first.reopen-duplicate;

ok $first.id//-2 != $copy.id//-1, "duplicated order should have different id ({$first.id} vs {$copy.id//-1})";
ok $expc == $copy.id//-1, "duplicated order should have .id = $expc { ($copy.id//-1) != $expc ?? "(GOT: {$copy.id//-1})" !! ''}";

$*CWD = $cwd;
