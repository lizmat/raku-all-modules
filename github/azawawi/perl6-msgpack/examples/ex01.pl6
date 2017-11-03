#!/usr/bin/env perl6

use v6;

#TODO remove lib
use lib 'lib';
use MsgPack;

my $data   = [1, True, "Example"];
my $packed = MsgPack::pack($data);

say $data.perl;
say $packed.perl;
