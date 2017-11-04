#!/usr/bin/env perl6

use v6;
use NativeCall;
use LibraryCheck;

constant LIB = 'msgpackc';

# ....
sub library {
	# Linux/Unix
	if library-exists(LIB, v2) {
		return sprintf('lib%s.so.2', LIB);
	} else {
		return sprintf('lib%s.so', LIB);
	}
}

=begin TODO
msgpack_object_print
msgpack_unpack
msgpack_vrefbuffer_append_copy
msgpack_vrefbuffer_append_ref
msgpack_vrefbuffer_clear
msgpack_vrefbuffer_destroy
msgpack_vrefbuffer_init
msgpack_vrefbuffer_migrate
msgpack_zone_clear
msgpack_zone_destroy
msgpack_zone_free
msgpack_zone_init
msgpack_zone_is_empty
msgpack_zone_malloc_expand
msgpack_zone_new
msgpack_zone_push_finalizer_expand
=end TODO

class msgpack_zone is repr('CStruct') {
	has int32 $something; #TODO implement msgpack_zone
}

class msgpack_unpacker is repr('CStruct') {
	has CArray[int8]          $buffer;
	has size_t       		  $used;
	has size_t 		 		  $free;
 	has size_t                $off;
	has size_t 		 		  $parsed;
 	has Pointer[msgpack_zone] $z;
 	has size_t 				  $initial_buffer_size;
 	has Pointer 		      $ctx;
}

class msgpack_object is repr('CStruct') {
	has int32 $.type is rw; # msgpack_object_type
	#TODO HAS msgpack_object_union $.via  is rw;
	has int32 $.c1 is rw;
	has int32 $.c2 is rw;
	has int32 $.c3 is rw;
	has int32 $.c4 is rw;
	has int32 $.c5 is rw;
}

sub msgpack_unpacker_init(Pointer[msgpack_unpacker] $mpac, size_t $initial_buffer_size)
	is native(&library)
	returns bool
	{ * }

sub msgpack_unpacker_new(size_t $initial_buffer_size)
	is native(&library)
	returns Pointer[msgpack_unpacker]
	{ * }

sub msgpack_unpacker_destroy(Pointer[msgpack_unpacker] $mpac)
	is native(&library)
	{ * }

sub msgpack_unpacker_free(Pointer[msgpack_unpacker] $mpac)
	is native(&library)
	{ * }

sub msgpack_unpacker_execute(Pointer[msgpack_unpacker] $mpac)
	is native(&library)
	returns int32
	{ * }

sub msgpack_unpacker_data(Pointer[msgpack_unpacker] $mpac)
	is native(&library)
	returns msgpack_object
	{ * }

sub msgpack_unpacker_expand_buffer(Pointer[msgpack_unpacker] $mpac, size_t $size)
	is native(&library)
	returns bool
	{ * }

sub msgpack_unpacker_release_zone(Pointer[msgpack_unpacker] $mpac)
	is native(&library)
	returns Pointer[msgpack_zone]
	{ * }

sub msgpack_unpacker_reset_zone(Pointer[msgpack_unpacker] $mpac)
	is native(&library)
	{ * }

sub msgpack_unpacker_reset(Pointer[msgpack_unpacker] $mpac)
	is native(&library)
	{ * }

enum msgpack_unpack_return <
	MSGPACK_UNPACK_SUCCESS,
	MSGPACK_UNPACK_EXTRA_BYTES,
	MSGPACK_UNPACK_CONTINUE,
	MSGPACK_UNPACK_PARSE_ERROR,
	MSGPACK_UNPACK_NOMEM_ERROR
>;

class msgpack_unpacked is repr('CStruct') {
	has int32 $something;
	#TODO msgpack_zone * 	zone
 	#TODO msgpack_object 	data
}

sub msgpack_unpack_next(
		Pointer[msgpack_unpacked] $result, Str $data, size_t $len,
		Pointer[size_t] $off
	)
	is native(&library)
	returns msgpack_unpack_return
	{ * }

sub msgpack_unpacker_next(Pointer[msgpack_unpacker] $mpac, Pointer[msgpack_unpacked] $pac)
	is native(&library)
	returns msgpack_unpack_return
	{ * }

sub msgpack_unpacker_flush_zone(Pointer[msgpack_unpacker] $mpac)
	is native(&library)
	returns bool
	{ * }

enum msgpack_object_type <
	MSGPACK_OBJECT_NIL
	MSGPACK_OBJECT_BOOLEAN
	MSGPACK_OBJECT_POSITIVE_INTEGER
	MSGPACK_OBJECT_NEGATIVE_INTEGER
	MSGPACK_OBJECT_FLOAT
	MSGPACK_OBJECT_STR
	MSGPACK_OBJECT_ARRAY
	MSGPACK_OBJECT_MAP
	MSGPACK_OBJECT_BIN
	MSGPACK_OBJECT_EXT
>;

class msgpack_packer is repr('CStruct') {
	has Pointer $.data is rw;
	#TODO has &callback (Pointer[void] $data, CArray[uint8], size_t $len) $.msgpack_packer_write;
}

# int(* 	msgpack_packer_write) (void *data, const char *buf, size_t len)
# void SetCallback(int (*callback)(const char *))
my sub SetCallback(&callback (Str --> int32)) is native('mylib') { * }

sub msgpack_pack_object(msgpack_packer $pk is rw, msgpack_object $d)
	is native(&library)
	returns int32
	{ * }

sub msgpack_object_print(Pointer $out, msgpack_object $o)
	is native(&library)
	{ * }

sub msgpack_object_equal(msgpack_object $x, msgpack_object $y)
	returns bool
	is native(&library)
	{ * }

say "nativesizeof(msgpack_object) = " ~ nativesizeof(msgpack_object);

#say "0";
my $o = msgpack_object.new;
$o.type = MSGPACK_OBJECT_BOOLEAN;
$o.c1 = 1;
my $pk = msgpack_packer.new;
#my $ret = msgpack_pack_object($pk, $o);
#say $ret;

#my Pointer $stdout := cglobal('libc.so.6', 'stdout', Pointer);
#msgpack_object_print($stdout, $o);

#say msgpack_object_equal($o, $o);

# vim: set tabstop=4:
