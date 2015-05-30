
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

  # TODO: X::Sum::Final used below when not adding, fix those.
}

=NAME Sum::libmhash - Raw Perl 6 bindings to libmhash

=begin SYNOPSIS
=begin code

    use Sum::libmhash;

    # Rawest interface, works directly with NativeCall objects:
    note "Algorithms supported by libmhash on this machine:";
    note <ID NAME PBLOCK-SIZE BLOCK-SIZE(result)>.fmt("%18.18s"," ");
    for %Sum::libmhash::Algos.pairs.sort -> $p ( :$key, :value($v) ) {
        note ($v.id,$v.name,$v.pblock_size,$v.block_size).fmt("%18.18s"," ");
    }

    my $md5 := Sum::libmhash::Instance.new("MD5");
    $md5.add(buf8.new(0x30..0x39));
    :256[$md5.finalize().values].base(16).say;
    # 781E5E245D69B566979B86E28D23F2C7

    # Slightly less raw interface:
    my $sha1 = Sum::libmhash::Sum.new("SHA1");
    $sha1.push(buf8.new(0x30..0x35));
    $sha1.pos.say; # 48
    $sha1.finalize(buf8.new(0x36..0x39)).Int.base(16).say;
    # 87ACEC17CD9DCD20A716CC2CF67417B71C8A7016
    $sha1.size.say; # 160
    $sha1.Buf.values.fmt("%x").say;
    # 87 ac ec 17 cd 9d cd 20 a7 16 cc 2c f6 74 17 b7 1c 8a 70 16

=end code
=end SYNOPSIS

# TODO: figure out how to attach this to a WHY which is accessible
# (or figure out how to get to another module's $=pod)

$Sum::libmhash::Doc::synopsis = $=pod[1].contents[0].contents.Str;

module Sum::libmhash {

use Sum;

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
# TODO: also ensure the size of hashid enum is properly determined and
#       used where appropriate.

our sub count() returns int is native('libmhash')
    is symbol('mhash_count') { * }

our $up = False;

our $count = Failure.new(X::AdHoc.new(:payload("libmhash initialization")));
try { $count.defined; $count = count(); }

$up = True if $count.defined;
$count = 0 unless $count.defined;

our sub name(int) returns str is native('libmhash')
    is symbol('mhash_get_hash_name_static') { * }

our sub block_size(int) returns int is native('libmhash')
    is symbol('mhash_get_block_size') { * }

our sub pblock_size(int) returns int is native('libmhash')
    is symbol('mhash_get_hash_pblock') { * }

=begin pod

=head2 class Sum::libmhash::Algo

    This class presents the contents of the table of algorithms
    presented by C<libmhash>.  The C<.id> attribute is the "hashid"
    used internally by the module to call C<libmhash> API
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

if ($up) {
    for 0..$count -> $b {
        if block_size($b) and name($b).defined {
            %Algos{$b} = Algo.new(:id(0+$b) :name(name($b))
                                  :block_size(block_size($b)),
                                  :pblock_size(pblock_size($b)))
        }
    }
}

my sub algo-by-name ($name) {
    my @ids = %Algos.keys.grep: { %Algos{$_}.name eq $name };
    return Failure.new(X::libmhash::NotFound.new(:field<name> :$name))
        if @ids.elems != 1;
    +@ids[0];
}

my $swab_4byte_digests = False;

=begin pod

=head2 class Sum::libmhash::Instance

    This class is a C<NativeCall CPointer> instance.  It has no
    state other than the raw C<libmhash> object representing
    an ongoing summation.

    The C<.add> method takes a single C<buf8> of any size.  Unlike
    the normal C<Sum::> role only C<.add> may be used to update
    the sum, C<.finalize> takes no optional data, will only
    produce results the first time it is called, and produces
    a C<buf8> rather than returning the original object.  There is no
    C<.push> method.

    The C<.new> constructor may take either the C<.id> or the
    C<.name> of a C<Sum::libmhash::Algo> to choose the algorithm,
    as a positional argument.

    Note that the C<.clone> C<Mu> method is fully functional on
    this class via the C<libmhash> C<cp> API function.

    A manual C<.free> method is not provided.  The resources
    will be freed when C<.finalize> is called, or if the object
    is abandoned, the class has some sentry hackery to ensure it
    is freed during garbage collection.  Since crypto resources
    may consume crypto hardware, it is recommended to always
    finalize these objects even if you have no use for the
    results.

=end pod

class Instance is repr('CPointer') {
      my %allocated = ();

      my sub init(int) returns Instance
          is native('libmhash')
          is symbol('mhash_init') { * };
      my sub deinit(Instance, CArray[int8])
          is native('libmhash')
          is symbol('mhash_deinit') { * };
      my sub mhash(Instance, blob8 $data, int $len) returns int
          is native('libmhash')
          is symbol('mhash') { * };
      my sub end(Instance) returns CArray[int8]
          is native('libmhash')
          is symbol('mhash_end') { * };
      my sub cp(Instance) returns Instance
          is native('libmhash')
          is symbol('mhash_cp') { * };
      my sub algo(Instance) returns int
          is native('libmhash')
          is symbol('mhash_get_mhash_algo') { * };
      my sub ca8_free(CArray[int8])
          is native
	  is symbol('free') { * };

      multi method new (Int $id) {
          return Failure.new(X::libmhash::NotFound.new(
	                     :field<id> :name($id)))
              unless %Algos{$id};
          my $res = init(+$id);
	  return Failure.new(X::libmhash::NativeError.new(:code<NULL>))
	      unless $res.defined;
	  %allocated{~$res.WHICH} = True;
	  $res;
      }

      multi method new (Str $name) {
          my $id = algo-by-name($name);
	  return $id unless $id.defined;
	  self.new($id);
      }

      method add(blob8 $data, Int $len = $data.elems)
      {
          return Failure.new(X::Sum::Final.new())
              unless %allocated{~self.WHICH}:exists;
          unless -1 < $len <= $data.elems {
              return Failure.new(X::OutOfRange.new(:what<index> :got($len)
                                                   :range(0..$data.elems)));
          }
	  # In case .elems > max size_t (int actually, until that gets fixed)
          my int $ilen = $len;
	  return Failure.new(X::AdHoc.new(:payload(
	      "Overflow assigning an Int to a size_t with managed memory")))
	      unless $ilen == $len;
	  my int $code = mhash(self, $data, $ilen);
          return Failure.new(X::libmhash::NativeError.new(:$code))
	      if $code;
	  True;
      }

      method finalize() {
          return Failure.new(X::Sum::Final.new())
              unless %allocated{~self.WHICH}:delete;
	  my $alg := %Algos{+algo(self)};
          my $c := end(self); # This deallocs everything
	  my $res := buf8.new($c[0..^$alg.block_size].list);
	  ca8_free($c);
	  $res := buf8.new($res.values.reverse)
	      if $swab_4byte_digests and $alg.block_size == 4;
	  $res;
      }

      method DESTROY() {
          if %allocated{~self.WHICH}:delete {
              deinit(self, CArray[int8]); # Type object should result in C NULL
          }
      }

      method clone() {
          return Failure.new(X::Sum::Final.new())
              unless %allocated{~self.WHICH}:exists;
          my $res = cp(self);
          return Failure.new(X::libmhash::NativeError.new(:code<NULL>))
	      unless $res.defined;
	  %allocated{~$res.WHICH} = True;
	  $res;
      }
}

# Do some runtime validation in case libmhash has been changed since install
if ($up) {
    my $md5 := Instance.new("MD5");
    fail("Runtime validation: could not make an Instance")
         unless $md5 ~~ Instance;

    my $message := Buf.new(0x30..0x37);
    $md5.add($message);
    my $digest := $md5.finalize();
    fail("mhash functional sanity test failed")
        unless $digest eqv buf8.new(0x2e,0x9e,0xc3,0x17,0xe1,0x97,0x81,0x93,
                                    0x58,0xfb,0xc4,0x3a,0xfc,0xa7,0xd8,0x37);

    # It seems mhash has some endian problems with 4-byte digests.
    # Check and compensate for that.
    # (There are no other 2..8-byte digest sizes but those may be broken too.)
    my $a32 := Instance.new("ADLER32");
    $a32.add($message);
    $digest := $a32.finalize();
    # There is something strange going on with how Buf unpacks, finagle for eqv
    $swab_4byte_digests = $digest.values eqv Array.new(0x9d,0x01,0x1c,0x07);
}

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

    The methods C<.pos>, C<.size> and C<.elems> both work as
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

    method size() { +self.block_size * 8 };

    method elems { self.pos };

    multi method add (blob8 $addends) {
        return Failure.new(X::Sum::Final.new()) unless defined $!inst;
	return unless $addends.elems;
        self.inst.add($addends, $addends.elems);
	$!pos += $addends.elems * 8;
    }

    # Take care to ensure the error message in this case.
    multi method add (Bool $b) {
       Failure.new(X::Sum::Marshal.new(:recourse<libmhash> :addend<Bool>));
    }

    method finalize(*@addends) {
        self.push(@addends) if @addends.elems;
	self.Buf;
        self
    }

    method Numeric () {
        return :256[$!res.values] if $!res.defined;
        return $!res if $!res.WHAT ~~ Failure;
        :256[self.Buf.values];
    };
    method Int () { self.Numeric }

    method buf8 () {
        return $!res if $!res.defined or $!res.WHAT ~~ Failure;
        $!res := self.inst.finalize();
        $!inst := Instance:U; # This has been freed by libmhash
        $!res
    }
    method Buf () { self.buf8 };
    method blob8 () { self.buf8 };
    method Blob () { self.buf8 };

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

$! = 0;

} # module

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2015 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<Sum::(pm3)> C<mhash(3)>
