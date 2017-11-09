
use v6;

unit module MsgPack::Native;

use NativeCall;

# ....
sub library {
    my $lib-name = sprintf($*VM.config<dll>, "msgpack-perl6");
    return ~(%?RESOURCES{$lib-name});    
}

class msgpack_sbuffer is repr('CStruct') is export {
    has size_t        $.size;
    has CArray[uint8] $.data;
    has size_t        $.alloc;
}

class msgpack_packer is repr('CStruct') is export {
	has Pointer $.data;
	has Pointer $.callback;
}

sub msgpack_sbuffer_init(msgpack_sbuffer $sbuf is rw)
    is native(&library)
    is symbol('wrapped_msgpack_sbuffer_init')
    is export
    { * }

sub msgpack_sbuffer_destroy(msgpack_sbuffer $sbuf is rw)
    is native(&library)
    is symbol('wrapped_msgpack_sbuffer_destroy')
    is export
    { * }

sub msgpack_packer_init(msgpack_packer $pk is rw, msgpack_sbuffer $sbuf is rw)
	is native(&library)
    is symbol('wrapped_msgpack_packer_init')
    is export
    { * }

sub msgpack_pack_nil(msgpack_packer $pk is rw)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_nil')
    is export
    { * }

sub msgpack_pack_true(msgpack_packer $pk is rw)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_true')
    is export
    { * }

sub msgpack_pack_false(msgpack_packer $pk is rw)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_false')
    is export
    { * }

sub msgpack_pack_array(msgpack_packer $pk is rw, size_t $n)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_array')
    is export
    { * }

sub msgpack_pack_map(msgpack_packer $pk is rw, size_t $n)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_map')
    is export
    { * }

sub msgpack_pack_bin(msgpack_packer $pk is rw, size_t $n)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_bin')
    is export
    { * }

sub msgpack_pack_bin_body(msgpack_packer $pk is rw, CArray[uint8] $b, size_t $l)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_bin_body')
    is export
    { * }

sub msgpack_pack_raw(msgpack_packer $pk is rw, size_t $n)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_raw')
    is export
    { * }

sub msgpack_pack_raw_body(msgpack_packer $pk is rw, CArray[uint8] $b, size_t $l)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_raw_body')
    is export
    { * }

sub msgpack_pack_int(msgpack_packer $pk is rw, int32 $d)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_int')
    is export
    { * }

sub msgpack_pack_float(msgpack_packer $pk is rw, num32 $d)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_float')
    is export
    { * }

sub msgpack_pack_double(msgpack_packer $pk is rw, num64 $d)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_double')
    is export
    { * }

sub msgpack_pack_str(msgpack_packer $pk is rw, size_t $l)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_str')
    is export
    { * }

sub msgpack_pack_str_body(msgpack_packer $pk is rw, Str $b, size_t $l)
    returns int32
    is native(&library)
    is symbol('wrapped_msgpack_pack_str_body')
    is export
    { * }

class msgpack_zone is repr('CStruct') is export {
    has uint64 $.filler1;
    has uint64 $.filler2;
    has uint64 $.filler3;
    has uint64 $.filler4;
    has uint64 $.filler5;
    has uint64 $.filler6;
    has uint64 $.filler7;
}

class msgpack_object_array is repr('CStruct') is export {
    has uint32 $.size;
    has Pointer $.ptr;  #TODO CArray[msgpack_object]
};

class msgpack_object_map is repr('CStruct') is export {
    has uint32  $.size;
    has Pointer $.ptr; #TODO CArray[msgpack_object_kv]
} ;

class msgpack_object_str is repr('CStruct') is export {
    has uint32        $.size;
    has CArray[uint8] $.ptr;
}

class msgpack_object_bin  is repr('CStruct') is export {
    has uint32        $.size;
    has CArray[uint8] $.ptr;
}

class msgpack_object_ext is repr('CStruct') is export {
    has int8          $.type;
    has uint32        $.size;
    has CArray[uint8] $.ptr;
}

class msgpack_object_union is repr('CUnion') is export {
    has bool                 $.boolean;
    has uint64               $.u64;
    has int64                $.i64;
    has num64                $.f64;
    HAS msgpack_object_array $.array;
    HAS msgpack_object_map   $.map;
    HAS msgpack_object_str   $.str;
    HAS msgpack_object_bin   $.bin;
    HAS msgpack_object_ext   $.ext;
}

class msgpack_object is repr('CStruct') is export {
    has uint32               $.type; 
    HAS msgpack_object_union $.via;
}

class msgpack_object_kv is repr('CStruct') is export {
    HAS msgpack_object $.key;
    HAS msgpack_object $.val;
}

class msgpack_unpacked is repr('CStruct') is export {
    has Pointer[msgpack_zone] $.zone is rw;
    HAS msgpack_object        $.data is rw;
}

enum msgpack_unpack_return is export (
    MSGPACK_UNPACK_SUCCESS     =>  2,
    MSGPACK_UNPACK_EXTRA_BYTES =>  1,
    MSGPACK_UNPACK_CONTINUE    =>  0,
    MSGPACK_UNPACK_PARSE_ERROR => -1,
    MSGPACK_UNPACK_NOMEM_ERROR => -2
);

sub msgpack_unpacked_init(msgpack_unpacked $result is rw)
    is native(&library)
    is symbol('wrapped_msgpack_unpacked_init')
    is export
    { * }

sub msgpack_unpack_next(msgpack_unpacked $result is rw,
    CArray[uint8] $data, size_t $len, size_t $off is rw)
    returns int32
    is native(&library)
    is export
    { * }

sub msgpack_unpacked_destroy(msgpack_unpacked $mpac is rw)
    is native(&library)
    is symbol('wrapped_msgpack_unpacked_destroy')
    is export
    { * }

sub msgpack_sbuffer_write(msgpack_sbuffer $data is rw, CArray[uint8] $buf, size_t $len)
    is native(&library)
    is symbol('wrapped_msgpack_sbuffer_write')
    is export
    { * }

enum msgpack_object_type is export (
    MSGPACK_OBJECT_NIL                  => 0x00,
    MSGPACK_OBJECT_BOOLEAN              => 0x01,
    MSGPACK_OBJECT_POSITIVE_INTEGER     => 0x02,
    MSGPACK_OBJECT_NEGATIVE_INTEGER     => 0x03,
    MSGPACK_OBJECT_FLOAT32              => 0x0a,
    MSGPACK_OBJECT_FLOAT64              => 0x04,
    MSGPACK_OBJECT_FLOAT                => 0x04,
    MSGPACK_OBJECT_DOUBLE               => 0x04, # obsolete
    MSGPACK_OBJECT_STR                  => 0x05,
    MSGPACK_OBJECT_ARRAY                => 0x06,
    MSGPACK_OBJECT_MAP                  => 0x07,
    MSGPACK_OBJECT_BIN                  => 0x08,
    MSGPACK_OBJECT_EXT                  => 0x09,
);

sub wrapped_msgpack_object_print(msgpack_object $obj)
    is native(&library)
    is export
    { * }

# msgpack/version.h
sub msgpack_version          is native(&library) is export returns Str   { * }
sub msgpack_version_major    is native(&library) is export returns int32 { * }
sub msgpack_version_minor    is native(&library) is export returns int32 { * }
#
# TODO handle backward compatibility under 1.0.0
# See https://github.com/msgpack/msgpack-c/blob/master/CHANGELOG.md
#
#sub msgpack_version_revision is native(&library) is export returns int32 { * }
