#!/usr/bin/env perl6

use lib 'lib';
use Koos::Searchable;
use Test;

plan 12;

class A does Koos::Searchable { submethod BUILD { $!inflate = False; } };

my $s  = A.new;
my %ah = ( a=>5,c=>6 );
my %ch = ( d=>8, '-or' => [(b=>500),(b=>400)] );
my %ao = ( fields => [qw<a>] );
my $tv = 1;
my %co = ( fields => [qw<a c d>], join => [
  { table => 'world', as => 'w', on => [('w.a' => 'a'), (l => $tv)] },
]);
my $a = $s.search(%ah, %ao);
my $c = $a.search(%ch, %co);

is-deeply $s.dump-filter, {}, 'original searchable filter is empty';
is-deeply $a.dump-filter, %ah, 'sub searchable is merge of new + old filter';
is-deeply $c.dump-filter, %(%ah, %ch), 'sub sub searchable is merge of inherited filter + new';

is-deeply $s.dump-options, {}, 'original searchable options empty';
is-deeply $a.dump-options, %ao, 'sub searchable is merge of new + old options';
is-deeply $c.dump-options, %(%ao, %co), 'sub sub searchable is merge of inherited option + new';

my $sq = $s.sql;
ok $sq<sql> ~~ m:i{^^'SELECT * FROM "dummy" as self'}, 'SELECT * FROM "dummy" as self';
ok $sq<params>.elems == 0, 'should be no params for first query';

$sq = $a.sql;
ok $sq<sql> ~~ m:i{^^'SELECT "a" FROM "dummy" as self WHERE ( "self"."'['a'|'c']'" = ? ) AND ( "self"."'['a'|'c']'" = ? )'}, 'SELECT "a" FROM "dummy" as self WHERE ( "self"."a" = ? ) AND ( "self"."c" = ? )';
is-deeply $sq<params>.sort, [5,6].sort, 'should be 2 params [5, 6]';

$sq = $c.sql;
ok $sq<sql> ~~ m:i{^^'SELECT "a", "c", "d" FROM "dummy" as self left outer join "world" as w on ( "w"."a" = "self"."a" ) AND ( "w"."l" = ? ) WHERE ( ( "self"."b" = ? ) OR ( "self"."b" = ? ) ) AND ( "self"."a" = ? ) AND ( "self"."d" = ? ) AND ( "self"."c" = ? )'}, 'SELECT "a", "c", "d" FROM "dummy" as self left outer join "world" as w on ( "w"."a" = "a" ) AND ( "l" = ? ) FROM ( ( "b" = ? ) OR ( "b" = ? ) ) AND ( "a" = ? ) AND ( "d" = ? ) AND ( "c" = ? )';
is-deeply $sq<params>.sort, [1, 500, 400, 5, 8, 6].sort, 'should be 5 params [1, 500, 400, 5, 8, 6]';
