#!/usr/bin/env perl6

use v6;
use lib './Tests';
use Bench;
use Document3;
use UUID;

my BSON::Javascript $js .= new(
  :javascript('function(x){return x;}')
);

my BSON::Javascript $js-scope .= new(
  :javascript('function(x){return x;}'),
  :scope(BSON::Document.new: (nn => 10, a1 => 2))
);

my UUID $uuid .= new(:version(4));
my BSON::Binary $bin .= new(
  :data($uuid.Blob),
  :type(BSON::C-UUID)
);

my BSON::ObjectId $oid .= new;

my DateTime $datetime .= now;

my BSON::Regex $rex .= new( :regex('abc|def'), :options<is>);

my $b = Bench.new;
$b.timethese(
  50, {
    '32 inserts' => sub {
      my BSON::Document $d .= new;

      $d<b> = -203.345.Num;
      $d<a> = 1234;
      $d<v> = 4295392664;
      $d<w> = $js;
      $d<abcdef> = a1 => 10, bb => 11;
      $d<abcdef><b1> = q => 255;
      $d<jss> = $js-scope;
      $d<bin> = $bin;
      $d<bf> = False;
      $d<bt> = True;
      $d<str> = "String text";
      $d<array> = [ 10, 'abc', 345];
      $d<oid> = $oid;
      $d<dtime> = $datetime;
      $d<null> = Any;
      $d<rex> = $rex;

      $d<ab> = -203.345.Num;
      $d<aa> = 1234;
      $d<av> = 4295392664;
      $d<aw> = $js;
      $d<aabcdef> = a1 => 10, bb => 11;
      $d<aabcdef><b1> = q => 255;
      $d<ajss> = $js-scope;
      $d<abin> = $bin;
      $d<abf> = False;
      $d<abt> = True;
      $d<astr> = "String text";
      $d<aarray> = [ 10, 'abc', 345];
      $d<aoid> = $oid;
      $d<adtime> = $datetime;
      $d<anull> = Any;
      $d<arex> = $rex;

      my BSON::Document $d2 .= new;
      $d2.decode($d.encode);
    }
  }
);

