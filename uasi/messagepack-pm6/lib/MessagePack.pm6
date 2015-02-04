use v6;

module MessagePack;

use MessagePack::Unpacker;

our sub unpack(Blob $data) {
    MessagePack::Unpacker.unpack($data);
}

our sub from-msgpack(Blob $data) is export {
    MessagePack::Unpacker.unpack($data);
}

# vim: ft=perl6

