#!/usr/bin/env perl6

use lib 'lib';
use lib 't/lib';
use DB::Xoos::SQLite;
use Test;
use DB::Xoos::Test;
use DB::SQLite;

plan 3;

configure-sqlite;

my $cwd = $*CWD;
$*CWD = 't'.IO;

my DB::Xoos::SQLite $d .=new;
my $db     = get-sqlite;

$d.connect(:$db, :options({
  prefix => 'X',
}));

my ($sth, $scratch);
my $e = $d.model('Multikey');
my $c = $e.new-row;
$c.key1('customer 1');
$c.key2('joe schmoe');
$c.val('xyz');
$c.update;


my $c2 = $e.new-row;
$c2.key1('customer 1');
$c2.key2('joe schmoe');
$c2.val('val');
my $err;
my $upd = -> {
  try {
    CATCH { default {  $err = $_; .rethrow } }; 
    $c2.update;
    $err = Any;
  };
};


dies-ok $upd;
ok $err.^can('message') && $err.message ~~ m:i{'constraint'}, 'update should fail because of key constraint';

$c2.key1('customer 2');
$upd();
ok Any ~~ $err, 'update should succeed with key1 changed';

$*CWD = $cwd;
