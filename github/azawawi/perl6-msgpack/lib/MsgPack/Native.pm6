
use v6;

unit module MsgPack::Native;

use NativeCall;
use LibraryCheck;

# ....
sub library {
    my $lib-name = sprintf($*VM.config<dll>, "msgpack-perl6");
    return ~(%?RESOURCES{$lib-name});    
}

# ....
sub libmsgpack {
    constant LIB = 'msgpackc';

    # macOS
    return "libmsgpackc.dylib" if $*KERNEL.name eq 'darwin';

	# Linux/Unix
	if library-exists(LIB, v2) {
		return sprintf('lib%s.so.2', LIB);
	} else {
		return sprintf('lib%s.so', LIB);
	}
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

# msgpack/version.h
sub msgpack_version          is native(&libmsgpack) is export returns Str   { * }
sub msgpack_version_major    is native(&libmsgpack) is export returns int32 { * }
sub msgpack_version_minor    is native(&libmsgpack) is export returns int32 { * }
#
# TODO handle backward compatibility under 1.0.0
# See https://github.com/msgpack/msgpack-c/blob/master/CHANGELOG.md
#
#sub msgpack_version_revision is native(&libmsgpack) is export returns int32 { * }
