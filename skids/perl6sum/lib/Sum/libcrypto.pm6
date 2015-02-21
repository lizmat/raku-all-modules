
module X::libcrypto {
  our class NotFound is Exception {
    has $.field;
    has $.name;
    method message {
      "No unique algorithm by $.field of $.name found in libcrypto."
    }
  }

  our class NativeError is Exception {
    has $.code = "undetermined";
    method message {
      "Error while talking to libcrypto: $.code"
    }
  }

  # TODO: X::Sum::Final used below when not adding, fix those.
}

=NAME Sum::libcrypto - Raw Perl 6 bindings to OpenSSL libcrypto digest API

=begin SYNOPSIS
=begin code

    use Sum::libcrypto;

    # Rawest interface, works directly with NativeCall objects:
    note "Algorithms supported by libcrypto on this system:";
    note <NAME NID BLOCK-SIZE SIZE>.fmt("%18.18s"," ");
    for %Sum::libcrypto::Algos.pairs.sort -> $p ( :$key, :value($v) ) {
        note ($v.name,$v.nid,$v.block_size,$v.size).fmt("%18.18s"," ");
    }

    my $md5 := Sum::libcrypto::Instance.new("md5");
    $md5.add(blob8.new(0x30..0x39));
    :256[$md5.finalize().values].base(16).say;
    # 781E5E245D69B566979B86E28D23F2C7

    # Slightly less raw interface:
    my $sha1 = Sum::libcrypto::Sum.new("sha1");
    $sha1.push(blob8.new(0x30..0x35));
    $sha1.pos.say;  # 48
    $sha1.finalize(blob8.new(0x36..0x39)).Int.base(16).say;
    # 87ACEC17CD9DCD20A716CC2CF67417B71C8A7016
    $sha1.size.say; # 160
    $sha1.Buf[].fmt("%x").say;
    # 87 ac ec 17 cd 9d cd 20 a7 16 cc 2c f6 74 17 b7 1c 8a 70 16

=end code
=end SYNOPSIS

# TODO: figure out how to attach this to a WHY which is accessible
# (or figure out how to get to another module's $=pod)

$Sum::libcrypto::Doc::synopsis = $=pod[1].contents[0].contents.Str;

module Sum::libcrypto {

use Sum;

=begin DESCRIPTION

    This module includes Perl6 C<NativeCall> glue to use the OpenSSL
    C<libcrypto> C library from Perl6 code.  These are internal
    implementations which can be used automatically without needing to
    specify that you want to use C<libcrypto> through the normal
    C<Sum::> interface.

    If an algorithm implemented by C<libcrypto> is not available through
    the normal interface, or if you are micro-optimizing, the classes
    contained herein are indeed intended to be used directly.  It is also
    possible to use these algorithms indirectly through C<Sum::librhash>.

    The libcrypto API is such that any algorithms added at a later date
    to libcrypto should be available without any changes necessary in
    this module; however it does not look to offer an enumerable catalogue,
    so any additions will not appear in C<%Sum::libcrypto::Algos> before
    they are explicitly requested by name.

    For portable checksums and digests, algorithm-specific
    C<Sum::> modules may utilize C<libcrypto> as a C<:recourse>
    when C<libcrypto> is detected, may utilize other C libraries,
    and may offer software fallback at the cost of some overhead.

=end DESCRIPTION

use NativeCall;

my  sub add_digests is native('libcrypto')
    is symbol('OpenSSL_add_all_digests') { * };

our $up = try { add_digests() }
# I have no clue why this is working or if it will continue to work
if $up.WHAT =:= Mu {
    $up = True;
}
else {
    $up = False;
}

=begin pod

=head2 class Sum::libcrypto::Algo

    This class presents the contents of the table of algorithms
    in C<libcrypto>.  The C<.name> attribute contains the name
    of the algorithm as presented by C<libcrypto>.

    The C<.size> contains the final digest's size in bytes.

    The C<.block_size> contains an internal block size of the
    algorithm, for example, the size of a NIST block and the
    size to which Merkle-Damgård padding must pad the
    last block, in bytes.

    Some algorithms presented by C<libcrypto> are automatically
    encapsulated into objects of this class, and then the variable
    C<%Sum::libcrypto::Algos> is built, indexing the objects by C<.name>.
    Because there seems to be no way to enumerate the table of
    algorithms, only agorithms from a hard-coded list will appear
    in C<%Sum::libcrypto::Algos> at first.  Algorithms present
    in C<libcrypto> which are not in the hard-coded list may still
    be used if requested by the name C<libcrypto> has assigned them.
    If the name is found, the corresponding entry in
    C<%Sum::libcrypto::Algos> will be added.

=end pod

class Algo {
    has Int $.nid;
    has Str $.name;
    has Int $.size;
    has Int $.block_size;
}

our %Algos;

our sub nid(OpaquePointer) returns int is native('libcrypto')
    is symbol('EVP_MD_type') { * }

our sub size(OpaquePointer) returns int is native('libcrypto')
    is symbol('EVP_MD_size') { * }

our sub block_size(OpaquePointer) returns int is native('libcrypto')
    is symbol('EVP_MD_block_size') { * }

our sub get_digestbyname(Str) returns OpaquePointer is native('libcrypto')
    is symbol('EVP_get_digestbyname') { * }

if ($up) {
    for <sha sha1 sha224 sha256 sha384 sha512
         md4 md5 dss1 ripemd160 md2 mdc2> -> $name {

    my $a := get_digestbyname($name);
    next unless $a.defined;
    %Algos{$name} = Algo.new(:$name :nid(nid($a)) :size(size($a))
                             :block_size(block_size($a)));
    }
}

=begin pod

=head2 class Sum::libcrypto::Instance

    This class is a C<NativeCall CPointer> instance.  It has no
    state other than the raw C<libcrypto> object representing
    an ongoing summation.

    The C<.add> method takes a single C<blob8> or C<buf8> of any
    size.  Unlike the normal C<Sum::> role only C<.add> may be
    used to update the sum, C<.finalize> takes no optional data,
    will only produce results the first time it is called, and
    produces a C<buf8> rather than returning the original object.
    There is no C<.push> method.

    The C<.new> contructor takes the C<.name> of a
    C<Sum::libcrypto::Algo> to choose the algorithm, as a positional
    argument.

    Note that the C<.clone> C<Mu> method is fully functional on
    this class via the C<libcrypto> C<EVP_MD_CTX_copy_ex> API function.

    A manual C<.free> method is not provided.  The resources
    will be freed when C<.finalize> is called, or if the object
    is abandoned; the class has some sentry hackery to ensure it
    is freed during garbage collection.  Since crypto resources
    may occupy crypto hardware, it is recommended to always
    finalize these objects even if you have no use for the
    results.

=end pod

class Instance is repr('CPointer') {
    my %allocated = ();

    my  sub create() returns Instance
        is native('libcrypto')
        is symbol('EVP_MD_CTX_create') { * };
    my  sub init(Instance, OpaquePointer, OpaquePointer) returns int
        is native('libcrypto')
        is symbol('EVP_DigestInit_ex') { * };
    my  sub destroy(Instance)
        is native('libcrypto')
        is symbol('EVP_MD_CTX_destroy') { * };
    my  sub update(Instance, blob8 $data, int $len) returns int
        is native('libcrypto')
        is symbol('EVP_DigestUpdate') { * };
    my  sub final(Instance, buf8 $data, OpaquePointer $size) returns int
        is native('libcrypto')
        is symbol('EVP_DigestFinal_ex') { * };
    my  sub copy(Instance $out, Instance $in) returns int
        is native('libcrypto')
        is symbol('EVP_MD_CTX_copy_ex') { * };
    my  sub algo(Instance) returns OpaquePointer
        is native('libcrypto')
        is symbol('EVP_MD_CTX_md') { * };

    multi method new (Str $name) {
        my $alg := get_digestbyname($name);
        return Failure.new(X::libcrypto::NotFound.new(:field<name> :$name))
              unless $alg.defined;
        unless %Algos{$name}:exists {
            %Algos{$name} = Algo.new(:$name :nid(nid($alg)) :size(size($alg))
                                     :block_size(block_size($alg)));
        }
        my $obj := create();
        return Failure.new(X::libcrypto::NativeError.new(:code<NULL>))
            unless $obj.defined;
        my $rcode := init($obj, $alg, OpaquePointer);
        return Failure.new(X::libcrypto::NativeError.new(:code<$rcode>))
            if $rcode != 1;
        %allocated{~$obj.WHICH} = True;
        $obj;
    }

    method add(blob8 $data, Int $len = $data.elems)
    {
        return Failure.new(X::Sum::Final.new())
            unless %allocated{~self.WHICH}:exists;
        unless -1 < $len <= $data.elems {
            return Failure.new(X::OutOfRange.new(:what<index> :got($len)
                                                 :range(0..$data.elems)));
        }

        # In case $data.elems > C MAXINT.
        my int $ilen = $len;
        unless $ilen == $len {
            return Failure.new(
                X::AdHoc.new(:payload("int wrap in NativeCall length arg.")));
        }

        # TODO check RC
        update(self, $data, $ilen);
    }

    method finalize() {
        return Failure.new(X::Sum::Final.new())
            unless %allocated{~self.WHICH}:delete;
        my $size = size(algo(self));
        my $res := buf8.new(0 xx ^$size);
        my $rcode := final(self, $res, OpaquePointer); # TODO size
        return Failure.new(X::libcrypto::NativeError.new(:code<$rcode>))
            if $rcode != 1;
        destroy(self);
#       return Failure.new(X::AdHoc(:payload("Alloc size != used size")))
#       if $size != $res.elems;
        $res;
    }

    method DESTROY() {
        if %allocated{~self.WHICH}:delete {
            destroy(self);
        }
    }

    method clone() {
        return Failure.new(X::Sum::Final.new())
            unless %allocated{~self.WHICH}:exists;
        my $obj := create();
        return Failure.new(X::libcrypto::NativeError.new(:code<NULL>))
            unless $obj.defined;
        my $rcode = copy($obj, self);
        return Failure.new(X::libcrypto::NativeError.new(:code<$rcode>))
            if $rcode != 1;
        %allocated{~$obj.WHICH} = True;
        $obj;
    }
}

# Do some runtime validation in case libcrypto has been changed since install
if ($up) {
    my $md5 := Instance.new("md5");

    fail("Runtime validation: could not make an Instance")
        unless $md5 ~~ Instance;

    my $message := blob8.new(0x30..0x37);
    $md5.add($message);
    my $digest := $md5.finalize();

    fail("Runtime validation: crypto functional sanity test failed") unless
        $digest eqv buf8.new(0x2e,0x9e,0xc3,0x17,0xe1,0x97,0x81,0x93,
                             0x58,0xfb,0xc4,0x3a,0xfc,0xa7,0xd8,0x37);
}

=begin pod

=head2 class Sum::libcrypto::Sum

    This is a predefined class that mostly behaves as if it
    C<"does Sum does Sum::Marshal::Raw">, but is just faking it.

    It is used internally by higher layers of the Sum:: stack.

    The C<.push> and C<.finalize> methods accept only C<buf8>
    arguments.  C<.add> accepts only a single C<buf8>.  Since
    libcrypto does not expose bit-level capabilities, you cannot
    add bits, only bytes, even when the algorithm supports it.
    On the bright side, you can pass any size C<buf8> without
    the need for a marshalling role.

    The methods C<.pos>, C<.elems>, and C<.size> all work as
    described in the C<Sum::> base role.  The units of these
    method are bits, not bytes, even for algorithms that do not
    have bitwise resolution, because there is no way to figure
    out which ones do or do not from the C<libcrypto> API.

    The C<.new> contructor takes the C<.name> of a
    C<Sum::libcrypto::Algo> to choose the algorithm, as a
    positional argument.

    The C<.clone> C<Mu> method is fully functional on this
    class.

    The class will proactively free all resources when
    the sum is finalized.  As crypto calculations may
    occupy dedicated crypto hardware, it is advised to
    always finalize sums even if you have no use for
    the results.

=end pod

class Sum {

    has $.algo handles<name nid block_size>;
    has Instance $.inst;
    has $!res;
    has $.pos = 0; # Always in bits; libcrypto hides bitwiseness

    multi method new (Str $name) {
        my $inst = Instance.new($name);
        return $inst unless $inst.defined;
        self.bless(*, :$inst, :algo(%Algos{$name}));
    }

    method clone() {
        my $inst = $!inst.clone;
        return $inst
            unless $inst.defined;
        self.bless(*, :$!pos, :$!res, :$!algo, :$inst);
    }

    method elems { self.pos };

    method size { +self.algo.size * 8 }

    multi method add (blob8 $addends) {
        return Failure.new(X::Sum::Final.new())
            unless defined $!inst;
        return unless $addends.elems;
        self.inst.add($addends, $addends.elems);
        $!pos += $addends.elems * 8;
    }

    # Take care to ensure the error message in this case.
    multi method add (Bool $b) {
       Failure.new(X::Sum::Marshal.new(:recourse<libcrypto> :addend<Bool>));
    }

    method finalize(*@addends) {
        self.push(@addends) if @addends.elems;
	self.Buf;
	self
    }

    method Numeric () {
        return :256[$!res.values] if $!res.defined;
        return $!res if $!res.WHAT ~~ Failure;
        :256[self.Buf.values]
    }
    method Int () { self.Numeric }

    method buf8 () {
        return $!res if $!res.defined or $!res.WHAT ~~ Failure;
        $!res := self.inst.finalize();
        $!inst := Instance; # This has been freed
        $!res
    }
    method blob8 () { self.buf8 }
    method Buf () { self.buf8 };
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

=begin COPYRIGHT

Copyright (c) 2015 Brian S. Julin. All rights reserved.

This product includes software developed by the OpenSSL Project
for use in the OpenSSL Toolkit. (http://www.openssl.org/)"

This product includes cryptographic software written by
Eric Young (eay@cryptsoft.com)"

=end COPYRIGHT
=begin LICENSE

NOTE: whether (and where) a product using this submodule is also required to
include the above copyright notices is situation dependent, per the terms
of the OpenSSL License and SSLeay dual license.  The submodule does expose
identifiers from the OpenSSL API, but this API is not exposed when using the
submodule through a higher layer C<Sum::> module.

You may use the C<:recourse> system in the main Sum modules to control
whether your program loads this submodule.  Also take care to
appropriately adjust your use of the C<librhash> submodule as per
your legal requirements.

This program is free software; you can redistribute it and/or modify it
under the terms of the Perl Artistic License 2.0.

=end LICENSE

=SEE-ALSO C<Sum::(pm3)> C<evp(3SSL)>
