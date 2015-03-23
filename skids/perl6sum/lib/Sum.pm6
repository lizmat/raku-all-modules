

class X::Sum::Push::Usage is Exception {
    method message {
        "Sums do not retain previous addends, so "
        ~ "push cannot return a useful value."
    }
}

class X::Sum::Final is Exception {
    method message {
        "Attempt to add more addends onto a finalized/finalizable Sum."
    }
}

class X::Sum::Missing is Exception {
    method message {
        "Attempt to finalize a Sum before all addends provided."
    }
}

class X::Sum::Spill is Exception {
    method message {
        "Maximum number of addends exceeded."
    }
}

class X::Sum::Marshal is Exception {
    has $.addend;
    has $.recourse = "";
    method message {
        my $recourse = " via recourse {$.recourse}";
        "Marshalling error.  Cannot handle addend of type $.addend$recourse."
    }
}

class X::Sum::Recourse is Exception {
    method message {
        "No acceptable recourse found.  Verify third-party library support."
    }
}

# Take care editing the pod here.  See below, and the t/sum.t test file.

=NAME Sum:: - Perl6 base roles for checksums and digests

=begin SYNOPSIS
=begin code
    use Sum;

    # Define a very simple Sum class that just adds normally
    class MySum does Sum::Partial does Sum
                does Sum::Marshal::Method[:atype(Str) :method<ords>] {
        has $.accum is rw = 0;
        method size { Inf }
        method finalize (*@addends) {
            self.push(@addends);
            self;
        }
        method Numeric () { self.finalize; $.accum; };
        method Int () { self.Numeric };
        method add (*@addends) {
            $.accum += [+] @addends;
        };
    }
    my MySum $s .= new();

    $s.push(3);
    $s.push(4);
    say +$s.finalize;                    # 7
    $s.push(5);
    say +$s.finalize;                    # 12

    # It can be used to tap a feed
    my @a <== $s <== (1,2);
    say @a;                              # 1 2
    say +$s.finalize;                    # 15

    # Since it does Sum::Partial, one can generate partials as a List
    $s.partials(1,1,2,1)».Int.say;       # 16 17 19 20

    # Since it does Sum::Marshal::Method[:atype(Str) :method<ords>]
    # Str addends are exploded into multiple character ordinals.
    'abc'.ords.say;                      # 97 98 99
    $s.partials(1,'abc',1)».Int.say;     # 21 118 216 315 316

=end code
=end SYNOPSIS

# This is a bit of a hack.  We want the test suite to be able to try to
# run the code in the synopsis.  When pod is more functional maybe this
# will become more maintainable.  In the meantime, if you edit anything
# above, take care to adjust the sections here.
$Sum::Doc::synopsis = $=pod[1].contents[0].contents.Str;

=begin DESCRIPTION
    This set of modules defines roles and classes for calculating checksums,
    hash values, and other types of sums.
=end DESCRIPTION

=begin pod

=head2 role Sum

    The C<Sum> role defines the core interface required for classes
    implementing various checksums and hashes.  It is generally not
    used directly, as it is pre-mixed into many other base roles in
    the C<Sum::> namespace.

    In addition to choosing a base C<Sum> role, classes should also
    mix in a C<Sum::Marshal> role which defines any special processing
    for slurpy lists of addends.  These are often not pre-mixed into
    derived roles, as the type of marshalling desired varies from
    application to application.

=end pod

role Sum:auth<skids>:ver<0.1.0> {

=begin pod
=head3 method finalize (*@addends)

    The C<.finalize> method returns the final result of a C<Sum> after enough
    addends have been provided.  If it is invoked before enough addends have
    been provided, it returns an C<X::Sum::Missing> failure.

    Some types of C<Sum> may throw away any interim state on finalization.
    In this case, any further attempt to provide more addends to the C<Sum>
    will return an C<X::Sum::Final> failure.

    Any addends provided in the C<@addends> list will be provided to the
    C<Sum> through its C<.push> method before finalization.  As such,
    this method can be used to produce a final value from addends in a
    single call:

        C<$checksum = MySum.new.finalize(1,3,5,7,9);>

    The C<.finalize> method actually just returns the Sum object, however,
    A C<Sum> will generally provide coercion methods, such as C<.Numeric>,
    so it can be treated as though it were a base type:

        C<MySum.new.finalize(1,3,5,7,9).Int.base(16).say;>

    Which coercion methods are available may vary across different types
    of C<Sum>.  In particular, sums will provide a C<.buf8> coercion
    method if their results are conventionally expressed in bytes, and
    a C<.buf1> coercion method if their results may contain a number of
    bits that does not pack evenly into bytes.  For convenience the latter
    may also provide a C<.buf8> method which should be LSB-justified.

    The C<.Buf> coercion method will eventually return one of the above
    results as natural to the type of C<Sum>, but given that C<buf1> is
    not implemented in the language core yet, some such methods return
    a C<Buf> at this time.  As such, explicit use of the C<.buf8> and
    C<.buf1> methods is advised in the interim.

    A C<.base(2)> multimethod will finalize the sum and print a text
    representation of the result.  Likewise, A C<.base(16)> multimethod
    will print an uppercase hex representation of the result.  A C<.fmt>
    method will also usually be made available, which is shorthand
    for C<.buf8.values.fmt($format,$separator)> with default values for
    a lowercase hex representation.  All three of these methods are
    special in that they will emit leading zeros.

    Note that a C<.Str> coercion method is currently not provided, until
    it can be established that nothing in the setting accidentally finalizes
    the sum by calling it.

=end pod

    method finalize (*@addends) { ... }  # Provided by class or role

    # Some methods to elide the need to convert to Int.  The individual
    # sums decide on how to do Numeric, but probably have no good
    # reason not to fool with these, so we can do some DRY control here.
    # We only cover common use cases.

    multi method base(2) {
        self.Numeric.fmt("%" ~ self.size ~ "." ~ self.size  ~ "b")
    }
    multi method base(16) {
        my $digits = (self.size + 3) div 4;
        self.Numeric.fmt("%" ~ $digits ~ "." ~ $digits ~ "X")
    }
    multi method fmt($format = "%2.2x", $sep = "") {
        self.buf8.values.fmt($format, $sep)
    }

=begin pod

=head3 method elems ()

    Some types of C<Sum> keep track of the total number of addends.  If not,
    this method will return an B<unthrown> C<X::Method::NotFound>.

    Otherwise, this method behaves similarly to the C<.elems> method
    of C<List> and C<Array>, and may even be an lvalue attribute for some
    types of C<Sum>.  Note, however, that only some types of C<Sum> support
    random access of addends, and most of those will only support write-once
    access to addends.

    Note also that unlike C<Array>, pushing to a C<Sum> pushes to the
    addend at the C<.pos> index, which is not necessarily the same as
    C<.elems>.

    When C<.elems> is an lvalue method and is explicity assigned to, the
    C<Sum> may not be finalized until addends at all indices have been
    provided, either through assignment, through a default value, or by
    pushing addends until C<.pos == .elems>.  This also applies when the
    type of C<Sum> has a fixed value for C<.elems>.

    Some types of C<Sum> may only support assigning to C<.elems> before
    the first addend is provided.

=end pod

    # Soften the exception for missing .elems method
    method elems () {
        fail(X::Method::NotFound.new(:method<elems> :typename(self.^name)))
    }

=begin pod

=head3 method pos ()

    Most types of C<Sum> allow addends to be provided progressively, such
    that large lists of addends acquired from asyncronous or lazy sources
    may be efficiently processed.  Many C<Sum>s will keep track of the
    index at which the next provided addend would be placed, but not all
    algorithms require maintaining this state.  For the few that do not,
    this method may return an B<unthrown> C<X::Method::NotFound>.

    Otherwise, this method returns the next index at which a provided
    addend will be placed.  Note that C<.pos> may in some cases be modulo.

    The C<.pos> method may also produce an lvalue when a C<Sum> supports
    random or streaming access, e.g. a rolling hash.  Some types of C<Sum>
    may only support assigning to C<.pos> before any addends have been
    supplied.

=end pod

    # Soften the exception for missing .pos
    method pos () {
        fail(X::Method::NotFound.new(:method<pos> :typename(self.^name)))
    }

=begin pod

=head3

    method push (*@addends --> Failure)

    Provide the values in C<@addends> to a C<Sum> starting with the addend
    at index C<.pos> and proceeding to subsequent indices.  C<.pos> is
    incremented as appropriate, as is C<.elems> in the case of dynamically
    sized types of C<Sum>.

    This method is also called when the C<Sum> is used as a feed tap.  (It
    is for this reason that it is named "push" rather than "update" as
    per NIST C conventions.)

    The values are "added" to the internal state of the C<Sum> according
    to the particular algorithm and the original values will be forgotten
    so the caller may safely destroy or alter them after the call returns.
    A finalization step is usualy not performed until requested, but might
    be, depending on the type of C<Sum>.

    The C<@addends> list may be eagerly evaluated, or not, depending on
    the exact type of C<Sum>.  Some types of C<Sum> only allow calling this
    method once, and some types of C<Sum> may place restrictions on the
    number or types of addends provided.

    The return value is always a C<Failure>.  Usually this will be an
    C<X::Sum::Push::Usage> which merely guards against naive use expecting
    C<Array.push> semantics.  An C<X::Sum::Missing> may be returned
    if a required number of addends is not met and the Sum cannot be
    resumed.  An C<X::Sum::Final> may be returned if the Sum is considered
    to have all its addends and may not accept more.

    The C<.push> method is usually provided by mixing in C<Sum::Marshal>
    roles, which define how addends lists are pre-processed and what types
    of addends are accepted.

=head3 method add (*@addends)

    The C<.add> method implements the raw arithmetic of the C<Sum>.
    It is usually not called directly, but rather is called as
    a back-end to the C<.push> method. Classes must implement
    or mix in this method.  It is expected to handle returning
    C<X::Sum::Missing> and C<X::Sum::Final> if needed.  Any
    Failure returned will be passed through to the caller of
    wrapping methods such as C<.push> or C<.finalize>.

    The type and number of arguments accepted by this method may
    vary depending on the type of C<Sum>.  Consult the relevant
    manpages.

=end pod

    method add (*@addends) { ... }

=begin pod

=head3 method size ()

    The C<.size> method returns the number of significant bits
    in the result.  It may be invoked on an instance or as a
    class method.  Note that in the case of a result obtained
    from the C<.buf1> coercion method, one may also just call
    C<.elems> on the result, but the equivalent may not be true of
    the result of the C<.buf8> coercion method, since the
    C<.buf8> method is available even when the number of bits
    in the result is not a multiple of 8.

=end pod

    method size () { ... }

    # The specs mention a .clear method when feeds are involved
    # but do not elaborate.
    #
    # Until we know when and how that will be called, we trap it.
    method clear (|parms) {
        die(".clear called and we don't know what it does yet.")
    }

}

=begin pod

=head2 role Sum::Partial

    The C<Sum::Partial> role is used to indicate that a sum may
    produce partial results at any addend index.

=end pod

role Sum::Partial {

=begin pod

=head3 method partials (*@addends --> List)

    The C<.partials> method acts the same as C<.push>, but returns
    a C<List> of the partial sums that result after finalizing the
    C<Sum> after every addend is provided.  Note that when the
    C<@addends> list is processed by any C<Sum::Marshal> roles, the
    number of partial sums may differ from the number of elements
    provided in C<@addends>.

    Note also that the finalization step for some types of C<Sum> may
    be computationally expensive.

    This method may promulgate C<Failure>s that occur during
    marshalling addends or adding them to the C<Sum>, by returning
    them instead of the expected results.

=end pod

    # This default method is satisfactory for sums that do not ruin their
    # state on finalization.  Sums that do, but which wish to provide
    # Sum::Partial anyway, should define their own overriding method that
    # clones the sum and finalizes the clone.  In those cases mixing in
    # Sum::Partial can still be done, but serves only to ensure that the
    # role is listed for introspective purposes.


    method partials (*@addends --> List) {
        # rakudo-m does not implement the "last" with a value conjectural
        # form from S04.  Neither does it provide &?BLOCK from which to
        # launch the method form .last($value).
#        flat self.marshal(|@addends).map: {
#            last($^addend) if $addend ~~ Failure;
#            given self.add($addend) {
#                when Failure { last($_) };
#            }
#            self.clone.finalize;
#        }
	# ...so this is just slapped together until then.
	eager self.marshal(|@addends).map: {
	        my $addend := $_;
		state $done = 0;
		last if $done;
	        if $addend ~~ Failure {
		    $done = 1;
                } else {
		    given self.add($addend) {
		        when Failure { $addend := $_; $done = 1;};
                        default { $addend := self.clone.finalize; };
                    }
		}
                $addend;
        }
    }
}

=begin pod

=head2 role Sum::Marshal::Raw

    The C<Sum::Marshal::Raw> role is used by classes that value efficiency
    over dwimmery.  A class with this role mixed in never processes
    single arguments as though they may contain more than one addend,
    nor combines multiple addends into a packed addend.  Addends are passed
    directly to the C<Sum>'s C<.add> method.

    The class will be less convenient to use as a result: the types of
    argument accepted by the C<.add> method vary depending on the
    underlying algorithm, so the user must consult the documentation
    for that particular type of sum.

    However, there will be less overhead involved, and it may result in
    easier code audits.

=end pod

role Sum::Marshal::Raw {

    method push (*@addends --> Failure) {
        # Pass the whole list to the class's add method, unprocessed.
        sink self.add(|@addends).grep({$_.WHAT ~~ Failure }).map:
             { return $_ };
        my $res = Failure.new(X::Sum::Push::Usage.new());
        $res.defined;
        $res;
    };

    # This allows simultaneous mixin of Sum::Partial
    multi method marshal (*@addends) { flat @addends };

}

=begin pod

=head2 role Sum::Marshal::Cooked

    The C<Sum::Marshal::Cooked> role is used by other C<Sum::Marshal>
    roles which provide dwimmery to addends.  It is usually not
    mixed in directly.  A class using a role that mixes
    C<Sum::Marshal::Cooked> will multi-dispatch each argument provided
    to the C<Sum> separately, such that arguments of different
    types may be processed, and perhaps even broken down into multiple
    addends.

=end pod

role Sum::Marshal::Cooked {

    # Subclasses may elect to handle finite numbers of addends in one
    # method call.  Where they do not, handle each one individually.
    multi method marshal ($self: :$diamond? where {True}, *@addends) {
        @addends.flat.map: { self.marshal(|$_.flat) }
    }

    # Last resort if no subclass has a handler for this specific type of
    # addend.  Pass the addend through, unless we are also one of the
    # marshalling types that has restrictions.
    multi method marshal ($self: $addend, :$diamond? where {True}) {
        # See if we are also a Sum::Marshal::Pack
        if self.^can('whole') and self.^can('violation') {

            # If we get an addend that is not otherwise handled by a
            # subclass, only pass it on if we are at a width boundary.
            # Otherwise issue an exception, since we do not know how
            # to pack the addend.
	    unless self.whole {
                $.violation = True;
                return Failure.new(X::Sum::Missing.new());
            }
        }
	return(|$addend);
    }

    # multi/constrained candidate to temporarily workaround diamond problem
    multi method push ($self: :$diamond? where {True}, *@addends --> Failure) {
        sink self.marshal(|@addends).map: {
            return $^addend if $addend ~~ Failure;
            given self.add($addend) {
                when Failure { return $_ };
            }
        };
        my $res = Failure.new(X::Sum::Push::Usage.new());
        $res.defined;
        $res;
    }
}

=begin pod

=head2 role Sum::Marshal::Method [ ::T :$atype, Str :$method, Bool :$remarshal = False ]
    does Sum::Marshal::Cooked

    The C<Sum::Marshal::Method> role will substitute any provided addend
    of type C<:atype> with the results of calling a method named C<:method>
    on that addend.  If a List results, it will be flattenned into the
    preceding list of addends.

    If the C<:remarshal> flag is provided, the results will instead
    be fed back through another marshalling level rather than being
    passed directly to the C<Sum>'s C<.add> method.  Note that care
    must be taken to avoid marshalling loops, and that this is not
    precisely equivalent to having the results appear in the original
    addend list.

=end pod

role Sum::Marshal::Method [ ::T :$atype, Str :$method, Bool :$remarshal = False ]
    does Sum::Marshal::Cooked {
    multi method marshal (T $addend) {
        given $addend."$method"() {
            return $_.flat unless $remarshal;
            self.marshal(|$_).flat;
        }
    }
}

=begin pod

=head2 role Sum::Marshal::Bits [ :$accept = Int, :$coerce = Int,
                                 :$bits = 8, :$reflect = False ]
            does Sum::Marshal::Cooked

    The C<Sum::Marshal::Bits> role will explode any argument of the type
    C<$accept> into bit values (currently we use Bools) after coercing
    the argument into the type C<$coerce>.  The parameter C<$bits>
    determines how many of the least significant bits of the result
    will be used to generate bit values, and hence the number of addends
    generated.  Bits outside this range are ignored silently
    (one could use type checking to get runtime errors by appropriately
    choosing and/or constraining types.)

    If C<:reflect> is provided, the bit values are emitted least
    significant bit first.

=end pod

role Sum::Marshal::Bits [ ::AT :$accept = (Int), ::CT :$coerce = (Int),
                          :$bits = 8, :$reflect = False ]
     does Sum::Marshal::Cooked {

    multi method marshal (AT $addend) {
        ?«($reflect ?? (1 X+& (CT($addend) X+> (^$bits)))
                    !! (1 X+& (CT($addend) X+> ($bits-1...0))));
    }

}

=begin pod

=head2 role Sum::Marshal::Pack [ :$width = 8 ]
            does Sum::Marshal::Cooked

    The C<Sum::Marshal::Pack> role is a base role.  One must also compose
    one or more C<Sum::Marshal::Pack::*> roles to use it.  These roles are
    used in situations where a C<Sum> works on addends of a certain width,
    but fragments of addends may be provided separately.  The fragments
    will be bitwise concatinated until a whole addend of C<$width> bits
    is available, and the whole addend (expressed as an Int) will then be
    added to the C<Sum>.

    Any leftover bits will be kept to combine with further fragments.
    However, if bits are left over when an addend is provided for
    which there is no corresponding C<Sum::Marshal::Pack::*> role,
    an C<X::Sum::Missing> unthrown exception will be returned.

    Classes which wish to allow these roles to be mixed in should
    call the C<.whole> method, when it is present, when finalizing a
    C<Sum>.  This will return an unthrown C<X::Sum::Missing> unless
    there are no leftover bits.

    Note that the C<pack> function may be used to pre-pack values,
    which can then be supplied to a less complicated type of C<Sum>.
    This will often be a better choice than using these roles.

=end pod

# These attributes must be mixed in at runtime for now until role
# composition handles diamond cronies correctly.

role Sum::Marshal::Pack::CronyWorkaround[ :$width ] {
    has $.bitpos_crony is rw = $width;
    has $.packed_crony is rw = 0;
    has $.width_crony is rw = $width;
    has $.violation_crony is rw = False;
}

role Sum::Marshal::Pack [ :$width = 8 ]
    does Sum::Marshal::Cooked {

    method crony_workaround($self is rw:) {
        unless $self ~~ Sum::Marshal::Pack::CronyWorkaround {
	    $self does Sum::Marshal::Pack::CronyWorkaround[ :$width ];
	}
    }

    multi method bitpos ($self is rw: :$diamond? where {True}) is rw {
        $self.crony_workaround;
	$self.bitpos_crony;
    }
    multi method packed ($self is rw: :$diamond? where {True}) is rw {
        $self.crony_workaround;
	$self.packed_crony;
    }
    multi method width ($self is rw: :$diamond? where {True}) is rw {
        $self.crony_workaround;
	$self.width_crony;
    }
    multi method violation ($self is rw: :$diamond? where {True}) is rw {
        $self.crony_workaround;
	$self.violation_crony;
    }

    # use multi/constrained method to workaround diamond problem
    multi method whole ($self: :$diamond? where {True}) {
        $.bitpos == $width and not $.violation
            ?? True
            !! Failure.new(X::Sum::Missing.new());
    }
}

=begin pod

=head2 role Sum::Marshal::Pack::Bits [ :$accept = Bool, :$coerce = Bool ]

    The C<Sum::Marshal::Pack::Bits> role packs bits into addends of a
    width defined by a C<Sum::Marshal::Pack> role, which must be composed
    along with this role.

    Any addend of the type specified by C<$accept> will be coerced into
    the type specified by C<$coerce>.  The truth value of the result will
    be used to determine whether the corresponding bit will be set or
    whether it will remain clear.

    This role may be combined with other C<Sum::Marshal::Pack::*> roles,
    such that these other addends may be bitwise concatenated along with
    single bit values.  Any type of addend that is not handled by one
    such role may only be added after a whole number of addends has been
    supplied, or the C<Sum> will become invalid and attempts to finalize
    or provide more addends will return an C<X::Sum::Missing>.

=end pod

role Sum::Marshal::Pack::Bits[::AT :$accept = (Bool), ::CT :$coerce = (Bool)]
{

    multi method marshal (AT $addend) {
        $.bitpos--;
        $.packed +|= 1 +< +$.bitpos if CT($addend);
        unless $.bitpos {
            my $packed = $.packed;
	    $.packed = 0;
            $.bitpos = $.width;
            return $packed;
        }
        return;
    }
}

=begin pod

=head2 role Sum::Marshal::Pack::Bits [ :$width!, :$accept, :$coerce = Int ]

    When the C<:width> parameter is supplied, the C<Sum::Marshal::Pack::Bits>
    role packs bitfields from provided addends.  This C<:width> parameter
    should not be confused with the C<:width> parameter of the
    C<Sum::Marshal::Pack> base role, which defines the width of the
    produced addends.

    Any addend of the type specified by C<$accept> will be coerced into
    the type specified by C<$coerce>.  The least C<:width> significant
    bits will be concatinated onto any leftover bits from previous results,
    and when enough bits are collected, the resultant will be provided
    as an C<Int> to the C<Sum>, keeping any remaining leftover bits to
    combine with further addends.

    The handling of leftover bits when a C<Sum> is finalized or when
    an addend not handled by a C<Sum::Marshal::Pack::*> role is provided
    proceeds as described above.

    Note that this role will not be especially useful until native types
    are available, unless the user defines an alternate integer-like type.

=end pod

role Sum::Marshal::Pack::Bits[:$width!, ::AT :$accept, ::CT :$coerce = (Int)]
{
    multi method marshal (AT $addend) {
        my $a = CT($addend);
        my $extrapos = max(0, $width - $.bitpos);
        if $extrapos {
            my $packed = $.packed +| ($a +> $extrapos);
            $.packed = $extrapos +& ((1 +< $extrapos) - 1);
            $.bitpos = $width - $extrapos;
            return $packed;
        }
        else {
            $.bitpos -= $width;
            $.packed +|= $a +< $.bitpos;
            unless $.bitpos {
                my $packed = $.packed;
	        $.packed = 0;
                $.bitpos = $.width;
                return $packed;
            }
        }
        return;
    }
}

=begin pod

=head2 role Sum::Marshal::Block [:$BufT = blob8, :$elems = 64, :$BitT = Bool]

    The C<Sum::Marshal::Block> role is a base role used to interface with
    types of sum that divide their message into NIST-style blocks.

    This role is usually not included directly, but rather through subroles.
    It is not compatible with any other C<Sum::Marshal> roles, unless
    those roles C<:remarshal> first.

    Classes which wish to allow these roles to be mixed in should
    call the C<.drain> method during finalization, if it is present,
    immediately after pushing any final addends, and C<.add> the result.
    After this method has been called, any further attempts to provide
    addends will result in an unthrown C<X::Sum::Final>.

    This base role contains fallback marshalling for C<BitT> addends which
    will be treated as bits and packed, C<BufT> addends whose values
    will be packed, and C<Any> addends which will be treated as C<Int>s
    and whose least significant bits will be packed as per the bit width
    of C<BufT>'s values.

=end pod

# These attributes must be mixed in at runtime for now until role
# composition handles diamond cronies correctly.
role Sum::Marshal::Block::CronyWorkaround {
    has @.accum_crony is rw;
    has @.bits_crony is rw;
    has Bool $.drained_crony is rw = False;
}

role Sum::Marshal::Block [::B :$BufT = blob8, :$elems = 64, ::b :$BitT = Bool]
    does Sum::Marshal::Cooked
{
    method crony_workaround($self is rw:) {
        unless $self ~~ Sum::Marshal::Block::CronyWorkaround {
	    $self does Sum::Marshal::Block::CronyWorkaround;
	}
    }

    multi method accum ($self is rw: :$diamond? where {True}) is rw {
        $self.crony_workaround;
	$self.accum_crony;
    }
    multi method bits ($self is rw: :$diamond? where {True}) is rw {
        $self.crony_workaround;
	$self.bits_crony;
    }
    multi method drained ($self is rw: :$diamond? where {True}) is rw {
        $self.crony_workaround;
	$self.drained_crony;
    }

    # Allow subroles to use our parameters.
    # use multi/constrained method to workaround diamond problem
    multi method B_elems ($self: :$diamond? where {True}) { $elems }
    multi method B ($self: :$diamond? where {True}) { B }
    multi method b ($self: :$diamond? where {True}) { b }

    my Int $bw = B.of.^nativesize;
    $bw ||= X::AdHoc::new(message => "dont know nativesize of " ~ B.of.gist );

    multi method marshal () { }

    # use multi/constrained method to workaround diamond problem
    multi method emit ($self: :$diamond? where {True}, *@addends) {
        @.accum.push(|@addends);

        # Emit any completed blocks.
        eager gather while (not @.accum.elems < $elems) {
            take B.new(@.accum.splice(0,$elems));
        }
    }

    # Multidispatch seems to need a bit of a nudge, thus the ::?CLASS
    multi method marshal (::?CLASS $self: b $addend where { True }) {
        return fail(X::Sum::Final.new()) if $.drained;

        @.bits.push($addend);
        return unless +@.bits == $bw;
        self.emit([+|] (+«@.bits.splice(0, $bw)) Z+< (reverse ^$bw));
    }

    multi method marshal (::?CLASS $self: B $addend where {not +$self.bits}) {
        return fail(X::Sum::Final.new()) if $.drained;

        eager gather do {
             my $i = 0;
             while ($addend.elems - $i + +@.accum >= $elems) {
                 take B.new(|@.accum, $addend[$i..^($i + $elems - +@.accum)]);
                 $i += $elems - +@.accum;
                 @.accum = ();
             }
             @.accum = $addend[$i ..^ $addend.elems];
        }
    }

    multi method marshal (::?CLASS $self: B $addend where { so +$self.bits }) {
        # punt on this mess for now
        self.marshal(|$addend.values);
    }

    multi method marshal (::?CLASS $self: $addend where { not +$self.bits }) {
        return fail(X::Sum::Final.new()) if $.drained;

        self.emit($addend);
    }

    multi method marshal (::?CLASS $self: $addend where {  so +$self.bits }) {
        return fail(X::Sum::Final.new()) if $.drained;

	# rakudo-m chokes on this
        # @.bits.push(?«(1 X+& ($addend X+> (reverse(^$bw)))));
	# ...so this is slapped together for now.  Or until better builtins.
	for reverse(^$bw) {
	    if ($addend +> $_) +& 1 {
	        @.bits.push(Bool::True);
            }
            else {
	        @.bits.push(Bool::False);
	    }
        }

        self.emit([+|] ((+«@.bits.splice(0, $bw)) Z+< reverse(^$bw)));
    }

    # use multi/constrained method to workaround diamond problem
    multi method drain ($self: :$diamond? where {True}) {
        $.drained = True;
	# Workaround for pre-GLR flattenning weirdness
        unless @.bits.elems {
	    return [B.new(@.accum)] if +@.accum;
	    return;
	}
        B.new(@.accum), ?«@.bits
    }
}

=begin pod

=head2 role Sum::Marshal::IO

    The C<Sum::Marshal::IO> role will take open C<IO> objects
    as addends, and provide their contents in an efficient manner
    to a C<Sum>.

    Currently this is done by repeatedly calling the C<.read> method
    of the object with a sensible chunk size, and providing the
    resulting values.  This may change as encoding and native type
    support is improved.

    This role may be mixed with C<Sum::Marshal::Block> roles in which
    case remarshalling is done using C<Buf>s.

=end pod

role Sum::Marshal::IO {

    # ^can("drain") is a poorman proxy for figuring out
    # if a Sum::Marshal::Block[...] is mixed in with us.
    multi method marshal (::?CLASS $self: IO $addend where { so $self.^can("drain") }) {

        gather while not $addend.eof {
            given $addend.read($.B_elems - +@.accum) {
                when Buf {
                    next unless $_.elems;
                    take flat self.marshal($_);
                }
                default {
                    take $_;
                    last;
                }
            }
        }
     }

    multi method marshal (IO $addend) {
        flat gather while not $addend.eof {
            given $addend.read(1024) {
                when Buf {
                    next unless $_.elems;
                    take flat $_.values;
                }
                default {
                    take $_;
                    last;
                }
            }
        }
    }
}

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2012 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<Sum::DWIM::(pm3)> C<Sum::Raw::(pm3)>

