use v6;

use Dependency::Sort;
use Test;
plan *;

my %h;
my %g;
%h<itemid> = 1;
%g<itemid> = 2;
%h<name>   = '1';
%g<name>   = '2';

my %j  = ( "itemid", 3, "name", 3 );
my %j4 = ( "itemid", 4, "name", 4 );

my $s = Dependency::Sort.new();

$s.add_dependency( %h, %g );
$s.add_dependency( %h, %j );

$s.add_dependency( %j, %j4 );
$s.add_dependency( %j, %g );

my $r = $s.serialise;

ok $r,"test success of operation";

ok $s.result.elems==4,"test result of operation";

my @a = (map {$_.<name>},$s.result);

my @b = ("2",4,3,"1");


ok  (@a eqv @b), "test result of operation 2";

#ok  ((map {$_.<name>},$s.result) === (("2",4,3,"1"))), "test result of operation 2";

#say $s.result.perl;

$s.add_dependency( %g, %j );

$r = $s.serialise;

ok !$r,"test failure of operation";

done-testing;
