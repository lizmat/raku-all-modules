
use v6;

unit module MsgPack;

use MsgPack::Native;

our sub pack( $data ) returns Blob
{
    my msgpack_sbuffer $sbuf = msgpack_sbuffer.new;
    my msgpack_packer $pk = msgpack_packer.new;

    msgpack_sbuffer_init($sbuf);
    msgpack_packer_init($pk, $sbuf);

    _pack($pk, $data);

    my @packed = gather {
        for 0..($sbuf.size - 1) {
            take 0xff +& $sbuf.data[$_];
        }
    }

    msgpack_sbuffer_destroy($sbuf);

    return Blob.new(@packed);
}

my multi sub _pack(msgpack_packer $pk, Any:U $thing) {
    msgpack_pack_nil($pk);
}

my multi _pack(msgpack_packer $pk, Numeric:D $f) {
    if $f.Int == $f {
        return _pack( $pk, $f.Int );
    }
    #TODO when to use msgpack_pack_float?
    msgpack_pack_double($pk, $f.Num);
}

my multi sub _pack(msgpack_packer $pk, List:D $list) {
    msgpack_pack_array($pk, $list.elems);
    _pack( $pk, $_ ) for @$list;
}

my multi sub _pack(msgpack_packer $pk, Bool:D $bool) {
    if $bool {
        msgpack_pack_true($pk);
    } else {
        msgpack_pack_false($pk);
    }
}

my multi sub _pack(msgpack_packer $pk, Int:D $integer) {
    msgpack_pack_int($pk, $integer);
}

my multi sub _pack(msgpack_packer $pk, Str:D $string) {
    my $len = $string.chars;
    msgpack_pack_str($pk, $len);
    msgpack_pack_str_body($pk, $string, $len);
}

our sub unpack( Blob $blob ) {
    ...
}

our sub version returns Hash {
    return %(
        major    => msgpack_version_major,
        minor    => msgpack_version_minor,
        revision => msgpack_version_revision,
        string   => msgpack_version);
}
