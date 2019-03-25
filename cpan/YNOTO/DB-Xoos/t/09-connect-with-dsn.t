#!/usr/bin/env perl6

use lib 'lib';
use lib 't/lib';
use DB::Xoos::SQLite;
use Test;
use DB::Xoos::Test;
use DBIish;
use X::Model::Order;

plan 2;

configure-sqlite;

my $cwd = $*CWD;
$*CWD = 't'.IO;

my DB::Xoos::SQLite $d .=new;

$d.connect('sqlite://test.sqlite3', :options({ :prefix<X> }));

ok True, 'connected to test.sqlite3 OK';

my $customers = $d.model('Customer');

ok $customers.count.defined, 'can count(*) from customers table';

$*CWD = $cwd;
