#!/usr/bin/env perl6

use v6;

#TODO remove lib
use lib 'lib';
use MsgPack;

my $data     = [1, True, "Example", { "that" => "rocks" }];
my $packed   = MsgPack::pack($data);
my $unpacked = MsgPack::unpack($packed);

say "data     : " ~ $data.perl;
say "packed   : " ~ $packed.perl;
say "unpacked : " ~ $unpacked.perl;
