#!/usr/bin/env perl6

use v6;

use Compress::Zlib::Raw;
use NativeCall;

my $to-compress = "test".encode;

my $return-buf-len = CArray[long].new;
$return-buf-len[0] = 128;

my $return-buf = buf8.new;
$return-buf[127] = 0;

my $result = compress($return-buf, $return-buf-len, $to-compress, 4);
die if $result != Compress::Zlib::Raw::Z_OK;

my $orig-buf = buf8.new;
$orig-buf[127] = 1;

my $orig-size = CArray[long].new;
$orig-size[0] = 128;

$result = uncompress($orig-buf, $orig-size, $return-buf, $return-buf-len[0]);
die if  $result != Compress::Zlib::Raw::Z_OK;
