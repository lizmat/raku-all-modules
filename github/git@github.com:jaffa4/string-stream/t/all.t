use v6;

use String::Stream;
use Test;
plan *;

my $o = String::Stream.new();

ok $o, "construction";

  my $t = String::Stream.new();

  print $t: "something";
 
  say $t: "something else";

  ok $t.buffer ~~ /somethingsomething/, "output test";


  my $res;
  {
 #  $*IN = String::Stream.new("puccini");

 #  $res =  prompt "composer> ";
  } 

 # ok $res ~~ "puccini", "input test";
  




done-testing;