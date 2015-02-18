
module X::librhash {
  our class NotFound is Exception {
    has $.field;
    has $.name;
    method message {
        "No unique algorithm by $.field of $.name found in librhash"
    }
  }

  # TODO: when we use this, see if we can get an error code out of nativeland
  our class NativeError is Exception {
    has $.code = "undetermined";
    method message {
        "Error while talking to librhash: $.code"
    }
  }

  our class Final is Exception {
    method message {
        "Attempt to double-finalize rhash context with raw API"
    }
  }

}

module Sum::librhash {

use Sum;

=NAME Sum::librhash - Raw Perl 6 bindings to librhash

=begin SYNOPSIS
=begin code

    use Sum::librhash;

    # Rawest interface, works directly with NativeCall objects:
    say "Largest librhash algo ID is $Sum::librhash::count";
    say "ID\tNAME\tBLOCK SIZE\tRESULT SIZE";
    for %Sum::librhash::Algos.pairs.sort -> $p ( :$key, :value($v) ) {
        say "{$v.id}\t{$v.name}\t{$v.digest_size}\t{$v.hash_length}";
    }

    my $md5 := Sum::librhash::Instance.new("MD5");
    $md5.add(buf8.new(0x30..0x39));
    # Note you must remember the size of your result ($.block_size above),
    # because the native librhash instance does not carry introspection
    :256[$md5.finalize(:bytes(16)).values].base(16).say;

    # Slightly less raw interface:
    my $sha1 = Sum::librhash::Sum.new("SHA1");
    $sha1.push(buf8.new(0x30..0x35));
    $sha1.pos.say;
    $sha1.finalize(buf8.new(0x36..0x39)).Int.base(16).say;
    $sha1.size.say;
    $sha1.Buf.say;

=end code
=end SYNOPSIS

=begin DESCRIPTION

    This module includes Perl6 C<NativeCall> glue to use the C<librhash>
    C library from Perl6 code.  These are internal implementations
    which can be used automatically without needing to specify that
    you want to use C<librhash> through the normal C<Sum::> interface.

    If an algorithm implemented by C<librhash> is not available through
    the normal interface, or if you are micro-optimizing, the classes
    contained herein are indeed intended to be used directly.

    The librhash API is such that any algorithms added at a later date
    to librhash should be available without any changes necessary in
    this module.

    For portable checksums and digests, algorithm-specific
    C<Sum::> modules may utilize C<librhash> as a C<:recourse>
    when C<librhash> is detected, may utilize other C libraries,
    and may offer software fallback at the cost of some overhead.

=end DESCRIPTION

use NativeCall;

my sub rhash_library_init is native('librhash')
    is symbol('rhash_library_init') { * }

# TODO: allow the user to explictly prevent all libssl interaction
# by allowing a way to delay this call during 'use' directive.
our $up = try { rhash_library_init(); }
# I have no clue why this is working or if it will continue to work
if $up.WHAT =:= Mu {
    $up = True;
}
else {
    $up = False;
}

# We offer this as a raw API but do not touch it ourselves, because as
# long as we do not, we do not have to worry about syncing to header
# enums.  This means the use of libssl is left to librhash default
# behavior.  It also means that the asyncronous features of librhash
# are not directly utilized.  The plan here is that the Sum suite
# will develop its own async features, and then we will revisit whether
# the librhash async features can be utilized on the back end of that.

# $msg_id should be uint
our sub transmit (int $msg_id, OpaquePointer $dst,
                  OpaquePointer $ldata, OpaquePointer $rdata) returns OpaquePointer
		  is native('librhash')
		  is symbol('rhash_transmit')
		  { * }

our sub count returns int is native('librhash')
    is symbol('rhash_count') { * }

our $count;
if ($up) {
    $count = count();
}

# $id should be uint
our sub digest_size (int $id) returns int is native('librhash')
    is symbol('rhash_get_digest_size') { * }

# $id should be uint
our sub hash_length (int $id) returns int is native('librhash')
    is symbol('rhash_get_hash_length') { * } # size of asciified presentation

# $id should be uint
our sub is_base32 (int $id) returns int is native('librhash')
    is symbol('rhash_is_base32') { * } # conventional asciification procedure

# $id should be uint
our sub name (int $id) returns str is native('librhash')
    is symbol('rhash_get_name') { * }

# $id should be uint
our sub magnet_name (int $id) returns str is native('librhash')
    is symbol('rhash_get_magnet_name') { * }

=begin pod

=head2 class Sum::librhash::Algo

    This class presents the contents of the table of algorithms
    presented by C<librhash>.  The C<.id> attribute is the integer
    ID used internally by the module to call C<librhash> API
    functions.  The C<.name> attribute contains the name of the
    algorithm as presented by C<librhash>.  The C<.digest_size>
    contains the final digest's size in bytes.  The C<.hash_length>
    contains the number of ASCII characters used when representing
    the digest results to humans, according to C<librhash>'s
    assessment of algorithm-specific common practices.  The
    C<.is_base32> attribute says whether the aforementioned
    format uses base32 ASCII encoding.  By appearences this
    is a boolean value not an enumeration of different Base32
    schemes, so it is treated thusly, but its type may change in
    future revisions if that turns out not to be the case.

    The C<.name> attribute contains C<librhash>'s preferred name
    for the algorithm, while the C<.magnet_name> may contain the
    name used for the algorithm in the MAGNET URI scheme.

    All algorithms presented by C<librhash> are encapsulated into
    objects of this class, and then the variable C<%Sum::librhash::Algos>
    is built, indexing the objects by C<.id>.

=end pod

class Algo {
    has Int $.id;
    has Str $.name;
    has Str $.magnet_name;
    has Int $.digest_size;
    has Int $.hash_length;
    has Bool $.is_base32;
}

our %Algos;

if ($up) {
    for 1,2,4,8 ...^ 1 +< $count -> $b {
        if digest_size($b) and name($b).defined {
            %Algos{$b} = Algo.new(:id(0+$b) :digest_size(+digest_size($b))
                                  :name(~name($b))
                                  :hash_length(+hash_length($b))
				  :is_base32(?is_base32($b))
			          :magnet_name(~magnet_name($b)))
        }
    }
}

my sub algo-by-name ($name) {
    my @ids = %Algos.keys.grep: { %Algos{$_}.name eq $name };
    return Failure.new(X::librhash::NotFound.new(
                       :field<name> :$name))
        if @ids.elems != 1;
    +@ids[0];
}

my sub algo-by-magnet-name ($name) {
    my @ids = %Algos.keys.grep: { %Algos{$_}.magnet-name eq $name };
    return Failure.new(X::librhash::NotFound.new(
                       :field<MAGNET> :$name))
        if @ids.elems != 1;
    +@ids[0];
}

=begin pod

=head2 class Sum::librhash::Instance

    This class is a C<NativeCall CPointer> instance.  It has no
    state other than the raw C<librhash> object representing
    an ongoing summation.  As such, when using this class, one
    must be able to keep track of which Sum::librhash::Algo is
    associated with the object.  This will be necessary to
    provide the mandatory C<:bytes> parameter to the C<.finalize>
    method, which returns a C<buf8> containing the resultant
    digest.  Also, only the first call to C<.finalize> will
    return a result, after which point the object will become
    useless.

    The C<.add> method takes a single C<buf8> of any size.  Unlike
    the normal C<Sum::> role only C<.add> may be used to update
    the sum, and C<.finalize> takes no optional data.  There is
    no C<.push> method.

    The C<.new> contructor may take either the C<.id> or the
    C<.name> of a C<Sum::librhash::Algo> to choose the algorithm,
    as a positional argument.  Alternatively the named parameter
    C<:magnet> may take the C<.magnet_name>.

    Note that the C<.clone> C<Mu> method is not operational
    on this class since C<librhash> offers no way to duplicate
    a instance state.  As such, using C<librhash> as a
    C<:recourse> when mixing C<Sum::Partial> is not supported.

    A manual C<.free> method is not provided.  The resources
    will be freed when C<.finalize> is called, or if the object
    is abandoned, the class has some sentry hackery to ensure it
    is freed during garbage collection.  Since crypto resources
    may consume crypto hardware, it is recommended to always
    finalize these objects even if you have no use for the
    results.

=end pod

# About cloning above: technically there might be a way
# to enable Sum::Partial but it is hinky: through the message
# API you can get an opaque pointer to an individual algorithm
# internal state.  This seems to only be used internally to sneak
# a peak at certain CRC32s before reading the check val at the end
# of a file.  There is no corresponding write function, and you
# do not know the size of that state.
#
# However if you ran an algorithm with a higher ID alongside
# it in the same container, pointer math could tell you that
# length.  Then you could create a new rhash object, get
# the pointer, and scribble the copied state onto it.
#
# I think we'll pass on that and see if rhash later offers a
# formal cloning API.

class Instance is repr('CPointer') {

      # This keeps track of allocated objects to avoid using
      # one that has been freed via the rhash API.  It must
      # hold a unique identifier, but NOT hold the object so
      # that the ObjAt can still be garbage collected.

      # This would be more efficient if we could set the
      # underlying CPointer to a sentry value and just
      # compare to that -- or better yet if undefine() worked
      # on classes such as this.
      my %allocated = ();

      # should be uint
      my sub init(int) returns Instance
          is native('librhash')
          is symbol('rhash_init') { * };
      my sub reset(Instance)
          is native('librhash')
          is symbol('rhash_reset') { * };
      my sub free(Instance)
          is native('librhash')
          is symbol('rhash_free') { * };
      # $len should be size_t
      my sub update(Instance, buf8 $data, int $len) returns int
          is native('librhash')
          is symbol('rhash_update') { * };
      my sub final(Instance, buf8) returns int
          is native('librhash')
          is symbol('rhash_final') { * };

      multi method new (Int $id) {
          return Failure.new(X::librhash::NotFound.new(
	                     :field<id> :name($id)))
              unless %Algos{$id};
          my $res := init(+$id);
	  return Failure.new(X::librhash::NativeError.new())
	      unless $res.defined;
	  %allocated{~$res.WHICH} = True;
	  $res;
      }
      multi method new (Str $name) {
          my $id = algo-by-name($name);
	  return $id unless $id.defined;
	  self.new($id);
      }
      multi method new (Str :$magnet) {
          my $id = algo-by-magnet-name($magnet);
	  return $id unless $id.defined;
	  self.new($id);
      }

      method add($data, $len = $data.elems)
      {
          return Failure.new(X::Sum::Final.new())
	      unless %allocated{~self.WHICH}:exists;
          # TODO check RC
          update(self, $data, +$len);
      }

      method finalize(:$bytes!) {
          return Failure.new(X::librhash::Final.new())
              unless %allocated{~self.WHICH}:exists;
	  my $res := buf8.new(|(0..^$bytes));

	  # Rhash double-finalize protection is crazy.
	  # IFF you have auto-finalize on, this is a noop if
          # already finalized, and no result will be written.
	  # But it still returns zero in that case.

	  # If you do not have auto-finalize on, it will happily
	  # try to do it, and then fail an assert if the low-level
	  # drivers detect a double finalize.  Which, depending
	  # on what assert means in a given environment, could
	  # do nothing, or abort, or...?
	  #
	  # If it does not abort, it still returns 0.
	  #
	  # If this is the first finalization, also returns 0.
	  #
	  # Also probably no check that it has not been
	  # canceled via the message-based API. (In fact
	  # that API has the potential to be expanded in
	  # other nefarious ways)

	  # In case rhash fixes this and returns an error
	  # for double finalizations, we future-proof,
	  # but for now this will never be reached.
          if (final(self, $res)) {
	      $res := Failure.new(X::librhash::Final.new());
	  }

	  # Remove our sentry to prevent future API calls.
	  %allocated{~self.WHICH}:delete;
	  free(self);
	  $res;
      }

      method DESTROY() {
          # Check if the user left this unfinalized
	  if %allocated{~self.WHICH}:delete {
              free(self);
	  }
      }

      method clone() {
          # Surprised core does not have this, so leaving as AdHoc.
          Failure.new(X::AdHoc.new(:payload("Cannot be cloned.")))
      }

}

# Do some runtime validation in case librhash has been changed since install
if ($up) {
    my $md5 := Instance.new("MD5");
    fail("Runtime validation: could not make an Instance")
        unless $md5 ~~ Instance;

    my $message := Buf.new(0x30..0x37);
    $md5.add($message);
    my $digest := $md5.finalize(:bytes(16));
    fail("rhash functional sanity test failed")
        unless $digest eqv buf8.new(0x2e,0x9e,0xc3,0x17,0xe1,0x97,0x81,0x93,
                                    0x58,0xfb,0xc4,0x3a,0xfc,0xa7,0xd8,0x37);
}

=begin pod

=head2 class Sum::librhash::Sum

    This is a predefined class that mostly behaves as if it
    C<"does Sum does Sum::Marshal::Raw">, but is just faking it.

    It is used internally by higher layers of the Sum:: stack.

    The C<.push> and C<.finalize> methods accept only C<buf8>
    arguments.  C<.add> accepts only a single C<buf8>.  Since
    librhash does not expose bit-level capabilities, you cannot
    add bits, only bytes, even when the algorithm supports it.
    On the bright side, you can pass any size C<buf8> without
    the need for a marshalling role.

    The methods C<.pos> and C<.elems> both all work as
    described in the C<Sum::> base role.  The units of these
    mehod are bits, not bytes, even for algorithms that do not
    have bitwise resolution, because there is no way to figure
    out which ones do or do not from the C<librhash> API.

    The C<.new> contructor may take either the C<.id> or the
    C<.name> of a C<Sum::librhash::Algo> to choose the algorithm,
    as a positional argument.  Alternatively the named parameter
    C<:magnet> may take the C<.magnet_name>.

    Note that the C<.clone> C<Mu> method is not operational
    on this class since C<librhash> offers no way to duplicate
    a instance state.  As such, using C<librhash> as a
    C<:recourse> when mixing C<Sum::Partial> is not supported.

=end pod


class Sum {

    has $.algo handles<id name magnet_name digest_size hash_length is_base32>;
    has Instance $.inst;
    has $!res;
    has $.pos = 0; # Always in bits; rhash hides bitwiseness

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

    multi method new (Str :$magnet) {
        my $id = algo-by-magnet-name($magnet);
        return $id unless $id.defined;
        self.new($id);
    }

    method clone() {
        # Surprised core does not have this, so leaving as AdHoc.
        Failure.new(X::AdHoc.new(:payload("Cannot be cloned.")))
    }

    submethod DESTROY() {
        unless $!res.defined {
            return;
        }
    }

    method size() { +self.algo.digest_size * 8 };

    method elems { self.pos };

    multi method add (blob8 $addends) {
        return Failure.new(X::Sum::Final.new()) unless defined $!inst;
	return unless $addends.elems;
        self.inst.add($addends, $addends.elems);
	$!pos += $addends.elems * 8;
    }

    # Take care to ensure the error message in this case.
    multi method add (Bool $b) {
       Failure.new(X::Sum::Marshal.new(:recourse<librhash> :addend<Bool>));
    }

    method finalize(*@addends) {
        self.push(@addends) if @addends.elems;
	self.Buf;
        self;
    }

    method Numeric () {
        return :256[$!res.values] if $!res.defined;
        return $!res if $!res.WHAT ~~ Failure;
        :256[self.Buf.values]
    }
    method Int () { self.Numeric }

    method buf8 () {
        return $!res if $!res.defined or $!res.WHAT ~~ Failure;
        $!res := self.inst.finalize(:bytes(self.algo.digest_size));
        $!inst := Instance; # This has been freed by librhash
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

=SEE-ALSO C<Sum::(pm3)> C<rhash(1)>
