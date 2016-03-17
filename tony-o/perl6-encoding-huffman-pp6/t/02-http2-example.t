#!/usr/bin/env perl6

use Encoding::Huffman::PP6;
use Test;

plan 2;

my Buf[uint8] $enc .=new(
  0xf1, 0xe3, 0xc2, 0xe5, 0xf2, 0x3a, 0x6b, 0xa0, 0xab, 0x90, 0xf4, 0xff 
);
my $dec = huffman-decode($enc);

ok $dec eq 'www.example.com', 'Decoding by pattern is fine.';

ok huffman-decode(huffman-encode("www.example.com")) eq "www.example.com", 'Encoding and decoding is fine.';
