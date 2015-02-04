
module X::libmhash {
  our class NotFound is Exception {
    has $.field;
    has $.name;
    method message {
        "No unique algorithm by $.field of $.name found in libmhash"
    }
  }

  # TODO: when we use this, see if we can get an error code out of nativeland
  our class NativeError is Exception {
    has $.code = "undetermined";
    method message {
        "Error while talking to libmhash: $.code"
    }
  }
}

module Sum::libmhash {

use Sum;

=NAME Sum::libmhash - Raw Perl 6 bindings to libmhash

=begin SYNOPSIS
=begin code

    use Sum::libmhash;

    # Rawest interface, works directly with NativeCall objects:
    say "Largest libmhash algo ID is $Sum::libmhash::count";
    say "ID\tNAME\tBLOCK SIZE\tRESULT SIZE";
    for %Sum::libmhash::Algos.pairs.sort -> $p ( :$key, :value($v) ) {
        say "{$v.id}\t{$v.name}\t{$v.block_size}\t{$v.pblock_size}";
    }

    my $md5 := Sum::libmhash::Instance.new("MD5");
    $md5.add(buf8.new(0x30..0x39));
    # Note you must remember the size of your result ($.block_size above),
    # because the native libmhash instance does not carry introspection
    :256[$md5.finalize(:bytes(16)).values].base(16).say;

    # Slightly less raw interface:
    my $sha1 = Sum::libmhash::Sum.new("SHA1");
    $sha1.push(buf8.new(0x30..0x35));
    $sha1.pos.say;
    $sha1.finalize(buf8.new(0x36..0x39)).base(16).say;
    $sha1.size.say;
    $sha1.Buf.say;

=end code
=end SYNOPSIS

=begin DESCRIPTION

    This module includes Perl6 C<NativeCall> glue to use the C<libmhash>
    C library from Perl6 code.  These are internal implementations
    which can be used automatically without needing to specify that
    you want to use C<libmhash> through the normal C<Sum::> interface.

    If an algorithm implemented by C<libmhash> is not available through
    the normal interface, or if you are micro-optimizing, the classes
    contained herein are indeed intended to be used directly.

    The libmhash API is such that any algorithms added at a later date
    to libmhash should be available without any changes necessary in
    this module.

    For portable checksums and digests, algorithm-specific
    C<Sum::> modules may utilize C<libmhash> as a C<:recourse>
    when C<libmhash> is detected, may utilize other C libraries,
    and may offer software fallback at the cost of some overhead.

=end DESCRIPTION

use NativeCall;

# Hackery alert: many of these "int"s are actually size_t in the mhash
# API.  That probably won't work too well when sizeof(int) != sizeof(size_t).
# TODO: fix these to use size_t when NativeCall gains support for it.

our sub count() returns int is native('libmhash')
    is symbol('mhash_count') { * }

our $count = count();

our sub name(int) returns str is native('libmhash')
    is symbol('mhash_get_hash_name_static') { * }

# Fortunately, this tells us where the holes are by returning 0.
our sub block_size(int) returns int is native('libmhash')
    is symbol('mhash_get_block_size') { * }

our sub pblock_size(int) returns int is native('libmhash')
    is symbol('mhash_get_hash_pblock') { * }

=begin pod

=head2 class Sum::libmhash::Algo

    This class presents the contents of the table of algorithms
    presented by C<libmhash>.  The C<.id> attribute is the integer
    ID used internally by the module to call C<libmhash> API
    functions.  The C<.name> attribute contains the name of the
    algorithm as presented by C<libmhash>.  The C<.block_size>
    contains the final digest's size in bytes.  The C<.pblock_size>
    contains an internal block size of the algorithm, for example,
    the size of a NIST block and the size to which Merkle-Damgård
    padding must pad the last block.

    All algorithms presented by C<libmhash> are encapsulated into
    objects of this class, and then the variable C<%Sum::libmhash::Algos>
    is built, indexing the objects by C<.id>.

=end pod

class Algo {
      has Int $.id;
      has Str $.name;
      has Int $.block_size;
      has Int $.pblock_size;
}

our %Algos;

for 0..$count -> $b {
    if block_size($b) and name($b).defined {
        %Algos{$b} = Algo.new(:id(0+$b), :block_size(block_size($b)),
                              :name(name($b)), :pblock_size(pblock_size($b)))
        }
}

my sub algo-by-name ($name) {
    my @ids = %Algos.keys.grep: { %Algos{$_}.name eq $name };
    return Failure.new(X::libmhash::NotFound.new(
                       :feild<name> :$name))
        if @ids.elems != 1;
    +@ids[0];
}

my $swab_4byte_digests = False;

=begin pod

=head2 class Sum::libmhash::Instance

    This class is a C<NativeCall CPointer> instance.  It has no
    state other than the raw C<libmhash> object representing
    an ongoing summation.  As such, when using this class, one
    must be able to keep track of which Sum::libmhash::Algo is
    associated with the object.  This will be necessary to
    provide the mandatory C<:bytes> parameter to the C<.finalize>
    method, which returns a C<buf8> containing the resultant
    digest.

    The C<.add> method takes a single C<buf8> of any size.  Unlike
    the normal C<Sum::> role only C<.add> may be used to update
    the sum, and C<.finalize> takes no optional data.  There is
    no C<.push> method, and any object abandoned before it has
    invoked its C<.finalize> method must be manually collected
    via the C<.destroy> method or memory will leak.

    The C<.new> contructor may take either the C<.id> or the
    C<.name> of a C<Sum::libmhash::Algo> to choose the algorithm,
    as a positional argument.

    Note that the C<.clone> C<Mu> method is fully functional on
    this class via the C<libmhash> C<cp> API function.

=end pod

class Instance is repr('CPointer') {
      my sub init(int) returns Instance
          is native('libmhash')
          is symbol('mhash_init') { * };
      my sub deinit(Instance, CArray[int8])
          is native('libmhash')
          is symbol('mhash_deinit') { * };
      my sub mhash(Instance, buf8 $data, int $len) returns int
          is native('libmhash')
          is symbol('mhash') { * };
      my sub end(Instance) returns CArray[int8]
          is native('libmhash')
          is symbol('mhash_end') { * };
      my sub cp(Instance) returns Instance
          is native('libmhash')
          is symbol('mhash_cp') { * };
      my sub ca8_free(CArray[int8])
          is native
	  is symbol('free') { * };

      multi method new (Int $id) {
          return Failure.new(X::libmhash::NotFound.new(
	                     :feild<id> :name($id)))
              unless %Algos{$id};
          my $res = init(+$id);
	  return Failure.new(X::libmhash::NativeError.new())
	      unless $res.defined;
	  $res;
      }
      multi method new (Str $name) {
          my $id = algo-by-name($name);
	  return $id unless $id.defined;
	  self.new($id);
      }

      method add($data, $len = $data.elems)
      {
          mhash(self, $data, +$len);
      }

      method finalize(:$bytes!) {
          my $c := end(self);
	  my $res := buf8.new($c[0..^$bytes].list);
	  ca8_free($c);
	  $res := buf8.new($res.values.reverse)
	      if $swab_4byte_digests and $bytes == 4;
	  $res;
      }

      # not DESTROY: the user of this class must call this manually iff
      # self.end has not been called.
      method destroy() {
          deinit(self, CArray[int8]); # Type object should result in C NULL
      }

      method clone() {
          cp(self);
      }
}

# Do some runtime validation in case libmhash has been changed since install
my $md5 := Instance.new("MD5");
fail("Runtime validation: could not make an Instance")
    unless $md5 ~~ Instance;

my $message := Buf.new(0x30..0x37);
$md5.add($message);
my $digest := $md5.finalize(:bytes(16));
fail("mhash functional sanity test failed") unless
    $digest eqv buf8.new(0x2e,0x9e,0xc3,0x17,0xe1,0x97,0x81,0x93,
                         0x58,0xfb,0xc4,0x3a,0xfc,0xa7,0xd8,0x37);

# It seems mhash has some endian problems with 4-byte digests.  Check for that.
# (There are no other 2..8-byte digest sizes but problems could be there, too.)
my $a32 := Instance.new("ADLER32");
$a32.add($message);
$digest := $a32.finalize(:bytes(4));
# There is something strange going on with how Buf unpacks, finagle for eqv
$swab_4byte_digests = $digest.values eqv Array.new(0x9d,0x01,0x1c,0x07);

=begin pod

=head2 class Sum::libmhash::Sum

    This is a predefined class that mostly behaves as if it
    C<"does Sum does Sum::Marshal::Raw">, but is just faking it.

    It is used internally by higher layers of the Sum:: stack.

    The C<.push> and C<.finalize> methods accept only C<buf8>
    arguments.  C<.add> accepts only a single C<buf8>.  Since
    libmhash does not expose bit-level capabilities, you cannot
    add bits, only bytes, even when the algorithm supports it.
    On the bright side, you can pass any size C<buf8> without
    the need for a marshalling role.

    The methods C<.pos>, C<.elems>, and C<.size> all work as
    described in the C<Sum::> base role.  The units of these
    mehod are bits, not bytes, even for algorithms that do not
    have bitwise resolution, because there is no way to figure
    out which ones do or do not from the C<libmhash> API.

    The C<.new> contructor may take either the C<.id> or the
    C<.name> of a C<Sum::libmhash::Algo> to choose the algorithm,
    as a positional argument.

    Note that the C<.clone> C<Mu> method is fully functional on
    this class via the C<libmhash> C<cp> API function.

=end pod

class Sum {

    has $.algo handles<id name block_size pblock_size>;
    has Instance $.inst;
    has $!res;
    has $.pos = 0; # Always in bits; mhash hides bitwiseness

    multi method new (Int $id) {
        my $inst = Instance.new($id);
	return $inst unless $inst.defined;
        self.bless(*,:$inst,:algo(%Algos{$id}));
    }

    multi method new (Str $name) {

        my $id = algo-by-name($name);
	return $id unless $id.defined;
	self.new($id);
    }

    method clone() {
        my $inst = $!inst.clone;
	return Failure.new(X::libmhash::NativeError.new())
	    unless $inst.defined;
        self.bless(*,:$!pos,:$!res,:$!algo,:$inst);
    }

    submethod DESTROY() {
        unless $!res.defined {
	    # We are discarding before finalization, so we need to free
            # the memory at $!inst.
            $!inst.destroy();
            return;
        }
    }

    method size() { (0 + self.block_size) * 8 };

    method elems { self.pos };

    multi method add (buf8 $addends) {
        return Failure.new(X::Sum::Final.new()) unless defined $!inst;
	return unless $addends.elems;
        self.inst.add($addends, $addends.elems);
	$!pos += $addends.elems * 8;
    }

    method finalize(*@addends) {
        self.push(@addends) if @addends.elems;
        return :256[$!res.values] if $!res.defined;
        return $!res if $!res.WHAT ~~ Failure;
        :256[self.Buf.values];
    }

    method Numeric () { self.finalize };

    method Buf () {
        return $!res if $!res.defined or $!res.WHAT ~~ Failure;
        $!res := self.inst.finalize(:bytes(self.algo.block_size));
        $!inst := Instance:U; # This has been freed by libmhash
        $!res
    }

    method push (*@addends --> Failure) {
        for (@addends) {
	    my $res = self.add($_);
	    return $res if $res ~~ Failure;
	}
        my $res = Failure.new(X::Sum::Push::Usage.new());
	$res.defined;
	$res;
    };

    multi method marshal (*@addends) { for @addends { $_ } };
}

} # module

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2015 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<Sum::(pm3)> C<mhash(3)>
