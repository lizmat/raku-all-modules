#!/usr/bin/env perl6

use Encoding::Huffman::PP6;
use Test;

plan 2;

my $enc = huffman-encode('aaba', {
  a    => 11,
  b    => 0,
  _eos => 10,
});

ok $enc eqv Buf[uint8].new(0xf7, 0x00);

my $dec = huffman-decode($enc, {
  a => 11,
  b => 0,
  _eos => 10,
});

ok $dec eq 'aaba';
