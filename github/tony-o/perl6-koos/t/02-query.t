#!/usr/bin/env perl6

use lib 'lib';
use Koos::Searchable;
use Test;

plan 4;

class A does Koos::Searchable { submethod BUILD { $!inflate = False; }; };

my $s = A.new;
my $f = {
  '-and' => [
    'w.x' => { '>' => 5 },
    'w.x' => { '<' => 500 },
  ],
  '-or' => [
    'w.y' => { '>' => 1 },
    'w.y' => -1,
  ],
};

my $o = {
  join => [
    {
      table => "judo",
      on => [ 'a' => 'a' ],
    },
  ]
};

my $a = $s.search($f, $o);

my %sq = $a.sql;
ok %sq<sql> ~~ m:i{^^'SELECT * FROM "dummy" as self left outer join "judo" on ( "judo"."a" = "self"."a" ) WHERE '}, 'SELECT * FROM "dummy" as self left outer join "judo" on ( "a" = "a" ) WHERE';
ok %sq<sql> ~~ m:i{('AND'?)'( ( "w"."y" '('>'|'=')' ? ) OR ( "w"."y" '('='|'>')' ? ) )'}, 'clause 1';
ok %sq<sql> ~~ m:i{('AND'?)'( ( "w"."x" '('>'|'<')' ? ) AND ( "w"."x" '('<'|'>')' ? ) )'}, 'clause 2';
is-deeply %sq<params>.sort, [-1,1,5,500].sort, 'got the params right';
