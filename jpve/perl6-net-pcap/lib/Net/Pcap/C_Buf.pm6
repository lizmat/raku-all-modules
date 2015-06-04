use NativeCall;
use nqp; # TODO: Get this code performant without using nqp! nqp is not portable.

=NAME
Net::Pcap::C_Buf;

=begin SYNOPSIS
    use NativeCall;
    use Net::Pcap::C_Buf :short :util;

    sub strerror_r(int $err, OpaquePointer $buf, int $len) returns int is native { * };

    my $buf = C_Buf.calloc(256);
    strerror_r(0xFFFFFFFF, $buf, 256);
    say $buf.decode('ascii');
=end SYNOPSIS

=begin EXPORTS
    class Net::Pcap::C_Buf

:short trait exports:

    constant C_Buf ::= Net::Pcap::C_Buf;

:util trait exports:

    sub C_calloc(...);
    sub C_malloc(...);
    sub C_memcpy(...);
    sub C_free(...);
=end EXPORTS

=begin DESCRIPTION

=end DESCRIPTION



=head2 Constants

=begin code
constant uint8p = CArray[uint8];
=end code

# Trick to stop complaints when passing CArray[uint8] to a CArray[uint8] signature.
my constant uint8p = CArray[uint8];



=head2 Subroutines

# The C builtin functions: calloc, malloc, memcpy, memfree
# TODO: change arguments to unsigned ints (size_t) when supported by NativeCall.

=begin code
C_calloc(int $nelem, int $elsize) returns OpaquePointer
    is export(:util)
  Interface to the C calloc() function.
=end code

my sub C_calloc(int $nelem, int $elsize) is export(:util)
    returns OpaquePointer
    is native is symbol('calloc') { * };



=begin code
C_malloc(int $size) returns OpaquePointer
    is export(:util)
  Interface to the C malloc() function.
=end code

my sub C_malloc(int $size) is export(:util)
    returns OpaquePointer
    is native is symbol('malloc') { * };



=begin code
C_memcpy(OpaquePointer $dst, OpaquePointer $src, int $n) returns OpaquePointer
    is export(:util)
  Interface to the C memcpy() function.
=end code

my sub C_memcpy(OpaquePointer $dst, OpaquePointer $src, int $n) is export(:util)
    returns OpaquePointer
    is native is symbol('memcpy') { * };



=begin code
C_free(OpaquePointer $ptr)
    is export(:util)
  Interface to the C free() function
=end code

my sub C_free(OpaquePointer $ptr) is export(:util)
    is native is symbol('free') { * };


=head2 class Net::Pcap::C_Buf
=begin code
does Positional
=end code

unit class Net::Pcap::C_Buf does Positional;
    
my constant C_Buf is export(:short) ::= Net::Pcap::C_Buf;



=head3 Attributes

=begin code
$.ptr             is OpaquePointer
$.carray          is uint8p
  Pointer to the C buffer
  $.carray contains this pointer cast to uint8p
  
$.elems           is Int
  Number of elements (bytes) in the buffer.

$.is_owner        is Bool
  Set if the Perl6 garbage collector needs to free the buffer before object destruction.

$.is_freed  is rw is Bool
  Set if the buffer has been free()'d.
=end code
	
has OpaquePointer $.ptr;
has uint8p $.carray;
has Buf $!buf;
has Int $.elems;
has Bool $.is_owner; # == 1 if we are responsible for calling free on the $.ptr.
has Bool $.is_freed is rw = False;



=head3 Methods

=begin code
.new(OpaquePointer $ptr, Int $elems, Bool $is_owner = True) returns C_Buf
.new(Buf $buf) returns C_Buf
  C_Buf constructor.
=end code

multi method new(OpaquePointer $ptr, Int $elems, Bool $is_owner = True) returns C_Buf {
    my $carray = nativecast(uint8p, $ptr);
    self.bless(:$ptr, :$carray, :$elems, :$is_owner, :is_freed(False));
}

multi method new(Buf $buf) {
    my $elems = $buf.elems;
    my $ptr = C_malloc($elems);
    my $carray = nativecast(uint8p, $ptr);
    for 0..^$elems -> $i {
	$carray[$i] = $buf[$i];
    }
    self.bless(:$ptr, :$carray, :$elems, :is_owner(True), :is_freed(False));
}



=begin code
.free()
  Free the buffer
=end code

method free() {
    if $.is_owner {
	die("C_Buf: already freed") if $.is_freed;
	
	C_free($.ptr);
	$.is_freed = True;
    }
}

method DESTROY() {
    self.free();
}



=begin code
.malloc(int $size) returns C_Buf
  Calls malloc and constructs a C_Buf for the return pointer.
=end code

method malloc(int $size) returns C_Buf {
    my $mem = C_malloc($size);
    C_Buf.new($mem, $size, True);
}



=begin code
.calloc(int $size) returns C_Buf
  Calls calloc and constructs a C_Buf for the return pointer.
=end code

method calloc(int $size) returns C_Buf {
    my $mem = C_calloc($size, 1);
    C_Buf.new($mem, $size, True);
}



=begin code
.clone() returns C_Buf
  Copies the buffer to a newly allocated area of memory and returns a C_Buf for the new buffer.
=end code

method clone() returns C_Buf {
    my $nptr = C_malloc($.elems);
    C_memcpy($nptr, $.ptr, $.elems);
    C_Buf.new($nptr, $.elems, True);
}



=begin code
.Buf() returns Buf
  Converts the C buffer to the builtin Buf type.
=end code

method Buf() returns Buf {
    return $!buf if defined($!buf);
    
    $!buf = Buf.new();
    for 0..^$.elems -> $i {
	$!buf[$i] = nqp::atpos_i(nqp::decont($.carray), nqp::unbox_i($i));
    }
    $!buf;
}



=begin code
.unpack_n(Int $i) returns Int
  Unpacks a 16-bit integer from the buffer, starting at position $i.
=end code

method unpack_n(Int $i) returns Int {
    return (self[$i] +< 8) + self[$i+1];
}



=begin code
.unpack_N(Int $i) returns Int
  Unpacks a 32-bit integer from the buffer, starting at position $i.
=end code

method unpack_N(Int $i) returns Int {
    return (self[$i] +< 24) + (self[$i+1] +< 16) + (self[$i+2] +< 8) + self[$i+3];
}



=begin code
.unpack(Str $str)
.unpack(Int $start, Str $str)
  Calls unpack($str) on the buffer.
  If $start is given, start unpacking at position $start.
=end code

multi method unpack(Str $str) {
    #self.Buf.unpack($str);
    # TODO: Fall back to self.Buf.unpack on unsupported symbols.
    return self.unpack(0, $str);
}

multi method unpack(Int $start, Str $str) {
    my Int $i = $start;
    my @fields;
    for $str.split('') -> $char {
	given $char {
	    when 'n' {
		@fields.push: self.unpack_n($i);
		$i += 2;
	    }
	    when 'N' {
		@fields.push: self.unpack_N($i);
		$i += 4;
	    }
	}
    }
    return |@fields;
}



=begin code
.subbuf(Int $from, Int $len = slef.elems) returns C_Buf
  Copy part of the buffer to a newly allocated memory region.
=end code

method subbuf(Int $from, Int $len = self.elems) returns C_Buf {
    my $end = $from + $len;
    die("C_Buf.subbuf: Length too small") if $end <= 0;
    die("C_Buf.subbuf: Argument from out of range") if $from > $.elems;
    $end = self.elems if ($from + $len > self.elems);

    my $start_ptr = OpaquePointer.new($.ptr.Int + $from);

    my $buf = C_Buf.malloc($end-$from);
    C_memcpy($buf.ptr, $start_ptr, $end-$from);
    $buf;
}



=begin code
.decode($encoding = 'utf-8') returns Str
  Converts the buffer to the builtin Buf type and calls .decode($encoding) on it.
  It is C-string aware, so if ($encoding eq 'ascii') it will stop decoding when it
  finds a 0x00 byte.
=end code

method decode($encoding = 'utf-8') returns Str {
    if ($encoding eq 'ascii') {
	# Special case because we know an ASCII encoded C string ends with a 0x00.
	my $buf = Buf.new();
	for 0..^$.elems -> $i {
	    my $char = nqp::atpos_i(nqp::decont($.carray), nqp::unbox_i($i));
	    last if $char == 0x00;
	    $buf[$i] = $char;
	}
	return $buf.decode('ascii');
    }
    self.Buf().decode($encoding);
}



=begin code
.at_pos(Int $pos) returns Int
  Returns the byte at position $pos. C_Buf does Positional so this code is called if C_Buf
  called with brackets like so $buf[1].
=end code
    
method AT-POS(Int $pos) returns Int {
    die("C_Buf: cannot retrieve position outside of array") if (($pos >= $.elems) || $pos < 0);
    my Int $i = nqp::atpos_i(nqp::decont($.carray), nqp::unbox_i($pos));
    if $i < 0 {
	$i = 0x100 + $i;
    }
    $i;
}



=begin code
.assign_pos(Int $pos, $assignee)
  Assignes the byte $assignee to position $pos. C_Buf does Positional so this code is called
  if the buffer is called with brackets to assign, like so: $buf[1] = 0;
=end code

method ASSIGN-POS(Int $pos, $assignee) {
    die("C_Buf: cannot assign position outside of array") if (($pos >= $.elems) || $pos < 0);
    $.carray[$pos] = $assignee;
}



=begin code
.bytes() returns Int
  Returns the number of bytes in the buffer.
=end code

method bytes() returns Int {
    $.elems;
}

