#!/usr/bin/env perl6

use lib 'lib';
use lib 't/lib';
use Koos;
use Test;
use Koos::Test;
use DBIish;

plan 2;

configure-sqlite;

my $cwd = $*CWD;
$*CWD = 't'.IO;

my Koos $d .=new;
my $db     = DBIish.connect('SQLite', database => 'test.sqlite3');

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
    CATCH { default {  $err = $_; } }; 
    $c2.update;
    $err = Any;
  };
};


$upd();
ok $err.^can('message') && $err.message ~~ m{'Primary key constraint violated: '}, 'update should fail because of key constraint';

$c2.key1('customer 2');
$upd();
ok Any ~~ $err, 'update should succeed with key1 changed';

$*CWD = $cwd;
