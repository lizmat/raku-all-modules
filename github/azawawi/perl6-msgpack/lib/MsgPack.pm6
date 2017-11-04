
use v6;

unit module MsgPack;

use NativeCall;
use MsgPack::Native;
use MsgPack::Packer;
use MsgPack::Unpacker;

our sub pack( $data ) returns Blob
{
    return Packer.new.pack($data);
}

our sub unpack( Blob $blob ) {
    return Unpacker.new.unpack($blob);
}

our sub version returns Hash {
    return %(
        major    => msgpack_version_major,
        minor    => msgpack_version_minor,
        string   => msgpack_version);
}
