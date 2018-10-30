#!/usr/bin/env perl6

use v6;
use lib './Test';

use Bench;
use BSON::Document;

my BSON::Document $d1 .= new;
$d1<int> = 0x7fffffff;
my Buf $buf1 = $d1.encode;

my BSON::Document $d2 .= new;
$d2<int> = 0x7fffffff_ffffffff;
my Buf $buf2 = $d2.encode;

my $b = Bench.new;
$b.timethese(
  2000, {
    '32 bit int with Promise encode' => sub {
      $d1 .= new;
      $d1<int> = 0x7fffffff;
      $buf1 = $d1.encode;
    },
    '32 bit int with Promise decode' => sub {
      $d1 .= new($buf1);
    },
    '64 bit int with Promise encode' => sub {
      $d2 .= new;
      $d2<int> = 0x7fffffff_ffffffff;
      $buf2 = $d2.encode;
    },
    '64 bit int with Promise decode' => sub {
      $d2 .= new($buf2);
    },
  }
);

say "$d1, $d2, ", $buf1.perl, ', ', $buf2.perl;
