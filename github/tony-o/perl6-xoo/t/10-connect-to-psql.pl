#!/usr/bin/env perl6

use lib 'lib';
use lib 't/lib';
use DB::Xoos::Pg;
use Test;

plan 2;

my $cwd = $*CWD;
$*CWD = 't'.IO;

my DB::Xoos::Pg $d .=new;

$d.connect('Pg://localhost/tonyo', :options({ :prefix<X> }));

ok True, 'Pg:: connected to localhost db=tonyo OK';

my $customers = $d.model('Customer');

ok $customers.count.defined, 'can count(*) from customers table';

$*CWD = $cwd;
