#!/usr/bin/env perl6

use v6;
#TODO remove lib
use lib 'lib';
use MsgPack;

my msgpack_sbuffer $sbuf = msgpack_sbuffer.new;
msgpack_sbuffer_init($sbuf);
my msgpack_packer $pk = msgpack_packer.new;
msgpack_packer_init($pk, $sbuf);
say $sbuf.size;

msgpack_pack_array($pk, 3);
msgpack_pack_int($pk, 1);
msgpack_pack_true($pk);
msgpack_pack_str($pk, 7);
msgpack_pack_str_body($pk, "example", 7);

say $sbuf.size;

my $values;
for 0..$sbuf.size-1 -> $i {
    $values.push: sprintf("%02X", 0xff +& $sbuf.data[$i]);
}
my $packed = $values.join(' ');
say "packed = '$packed'";

msgpack_sbuffer_destroy($sbuf);

say "Done";
