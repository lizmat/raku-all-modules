
=NAME Sum::MDPad - Merkle-Damgård padding for Sum:: roles

=begin SYNOPSIS
=begin code
    use Sum::MDPad;

    role mySum does Sum::MDPad[:blocksize(1024)] does Sum::Marshal::Raw {...}
=end code
=end SYNOPSIS

=DESCRIPTION Support code for common Merkle-Damgård-compliant padding schemes

=begin pod

=head1 ROLES

=head2 role Sum::MDPad [ :$blocksize :$lengthtype :$overflow :@firstpad :@lastpad :justify ]
            does Sum {

    The C<Sum::MDPad> parametric role defines an interface and shared
    code which is useful for types of C<Sum> which use prevalent variations
    of Merkle-Damgård-compliant padding.  This is a system for breaking
    to-be-hashed messages up into blocks.  It defines a format used in
    the last blocks, which contain the remainder of the message, a
    pad marker, padding, and a message length field.

    The role parameter C<:blocksize> sets the size of message blocks in
    bits.  The C<:firstpad> parameter specifies a bit pattern appended
    to the message before zero-padding.  Currently this must be an Array
    of Bool values, and defaults to C<[True]>, which causes one set bit
    to be appended before padding the unused portion of the last block
    with clear bits.  The C<:lastpad> parameter specifies a similar bit
    pattern placed at the end of the padding, before any embedded length
    field, and it is empty by default.

    The C<:lengthtype> and C<:overflow> parameters control the format
    and behavior of the length counter and are described with the relevant
    methods below.

    The C<:justify> parameter is mainly for use with obselete algorithms.
    If set to True, before appending the bits in :firstpad the used bits
    within the last used byte of the sum are shifted left to occupy the least
    significant bit position, and the remaining most significant bit
    positions, in ascending order of significance, are filled with the
    bits from :firstpad.  The only current use cases for this so far
    are when :firstpad contains a single True bit so the behavior when
    that is not the case is undefinied.

    The thinking behind the padding scheme that uses C<:justify> is that
    bits of the message are shifted bitwise, most-significant-bit-first,
    into the least significant side of each byte of the buffer in turn.
    When there are 8 bits worth of data remaining in the message this is
    the same as just setting that buffer byte to the corresponding message
    byte.  When there are less, this leaves the message data right-justified
    in the buffer byte.  This somewhat makes sense, but then an
    incongruity is introduced because the padding is not similarly shifted
    into the buffer byte; instead it is placed in the next unused bits.

    Values other than True may eventually be added to the :justify parameter
    to allow computations of old checksums where the checksums were generated
    by libraries which had misinterpreted this padding scheme.

=end pod

use Sum;

# The newlines in the parameter list here should not need to be here.  Star 2013.11 regression.
# Also the eqv can be written "where one <...>" but the braces seem to help the parser as well
role Sum::MDPad [ int :$blocksize where { not $_ % 8 }
                                                       = 512, :$lengthtype where { $_ eqv one("uint64_be","uint64_le","uint128_be","uint128_le") }
                                                                                                                                                   = "uint64_be", Bool :$overflow = True, :@firstpad = (True,), :@lastpad, Bool :$justify = False ] does Sum {
# above is workaround for RT119267, should be this:
#                                                                    = "uint64_be", Bool :$overflow = True, :@firstpad = [True], :@lastpad, Bool :$justify = False ] does Sum {
    my $bbytes = $blocksize/8;
    my $lenshifts;

    given $lengthtype {
        when "uint64_le" { $lenshifts := (0, 8, 16, 24, 32, 40, 48, 56) }
        when "uint128_le" { $lenshifts := (0,8...^128) }
        when "uint64_be" { $lenshifts := (56,48...0) }
        when "uint128_be" { $lenshifts := (120,112...0) }
        # TODO: other widths of counter, as needed
    }
# above is workaround for RT119267, should be this:
#    my @lenshifts = (
#        given $lengthtype {
#            when "uint64_le" { (0,8...^64) }
#            when "uint128_le" { (0,8...^128) }
#            when "uint64_be" { (56,48...0) }
#            when "uint128_be" { (120,112...0) }
#            # TODO: other widths of counter, as needed
#        }
#    );

=begin pod

=head2 method pos

    The C<Sum::MDPad> role handles the C<.pos> method, keeping track of how
    many bits of message have been provided to the sum.  The C<:lengthtype>
    role parameter determines how it is stored in the padding.  Until sized
    unsigned types are available, it should be set to the string "uint64_be"
    or the string "uint64_le" to specify storage in big-endian or
    little-endian format, respectively, or for 128-bit lengths, "uint128_be"
    or "uint128_le".  These are the only four formats currently supported.

    The C<:overflow> role attribute specifies whether the sum should fail
    if a message larger than the C<:lengthtype> can express is provided,
    or simply truncate higher bits off the length counter when storing it
    in the final block.  The default is C<True>, the latter, which is
    relatively benign with large counter sizes.  The option is mainly provided
    for strict specification compliance, and will rarely be relevant in
    common usage scenarios.

=end pod

    has Int $!o = 0;
    method pos () { $!o };

=begin pod

=head2 method elems

    The C<Sum::MDPad> role handles the C<.elems> method, which also
    has units of bits.  Immediately after a sum is created, but before
    supplying addends, this method may be used as an lvalue to set an
    expected (nonzero) size for the message.  The behavior in this case
    is as described in the C<Sum> base interface.

    If not set explicitly, this method simply returns the same value as
    the C<.pos> method.

=end pod

#    The lvalue behavior may be used in the future to allow optional
#    length-bearing message prefixes when the message length is presaged,
#    as there are proposals floating around about doing that.  Using it
#    now for convenience purposes should be forward compatible; prepending
#    such a prefix should be made to require an additional role parameter,
#    rather than having it happen automatically when lvalue access is used.

    has Int $!expect = 0;
    method elems () is rw {
        my $f := self;
        Proxy.new(
            FETCH => { $!expect ?? $!expect !! $!o },
            STORE => -> $self, $v {
                if $!o {
                    Failure.new(X::AdHoc.new(:payload("Cannot presage length after providing addends.")))
                }
                else {
                    $!expect = $v
                }
            }
        );
    }

=begin pod

=head2 method pos_block_inc

    The C<!pos_block_inc> method should be called by the C<.add>
    multi-candidate which handles complete blocks, in order to update
    the message bit count.  This will be a private method which only
    composers may use, but is currently public (C<.pos_block_inc>).

    It automatically handles finagling the count on the last blocks,
    so from the composer's side it should simply be called once for
    each full block processed.  It also automatically handles checking
    for extra addends pushed to a finalized sum, and for length
    violations when C<.elems> has been explicity set to a nonzero value.
    As such any failures returned should abort the sum and be returned
    directly.

=end pod

    has Bool $!ignore_block_inc = False;
    has Bool $.final is rw = False;
    method pos_block_inc () {
        return if $!ignore_block_inc;
        fail(X::Sum::Final.new()) if $.final;
        unless ($overflow) {
            fail(X::Sum::Spill.new())
                if $!o >= (1 +< ($lenshifts.elems * 8)) - $blocksize;
        }
        fail(X::Sum::Spill.new()) if $!expect and $!o + $blocksize > $!expect;
        $!o += $blocksize;
        return;
    }

=begin pod

=head2 multi method add

    The C<Sum::MDPad> role provides multi candidates for the C<.add>
    method which handle erroneous addends, missing addends, and short
    blocks.  The algorithm-specific code which mixes in C<Sum::MDPad>
    need only provide a single additional candidate which processes
    one complete block of message.

    The resulting C<Sum> expects a C<buf8> or C<blob8> with C<blocksize/8>
    elements.  Passing a shorter buffer with C<0..^blocksize/8> elements may
    be done once, before or during finalization.  Such a short buffer may
    optionally be followed by up to 7 bits (currently, 7 xx Bool) if the
    message does not end on a byte boundary.  Attempts to provide more
    blocks after passing a short block will result in an C<X::Sum::Final>.

    Note that C<.add> does not handle slurpy argument lists, and when
    using C<Sum::Marshal::Raw>, one call to C<.push> should be made per
    block.  Slurpy lists may be C<.push>ed if C<Sum::Marshal::Block> roles
    are mixed instead.

=end pod

    proto method add (|c) {*}
    multi method add ($addend) {
        fail(X::Sum::Marshal.new(:addend($addend.WHAT.^name)))
    }
    multi method add () { }
    multi method add (blob8 $block where { -1 < .elems < $bbytes },
                      Bool $b7?, Bool $b6?, Bool $b5?, Bool $b4?,
                      Bool $b3?, Bool $b2?, Bool $b1?) {
	if $.final {
            fail(X::Sum::Final.new()) if ($block.elems or $b7.defined);
            return;
	}
        my @bcat = ();
        @bcat.push($_) if .defined for ($b7,$b6,$b5,$b4,$b3,$b2,$b1);
        my int $bits = @bcat.elems;

        my int $inc = $block.elems * 8 + $bits;
        unless ($overflow) {
            fail(X::Sum::Spill.new())
                if $!o >= (1 +< ($lenshifts.elems * 8)) - $inc;
        }
        if $!expect {
            fail(X::Sum::Spill.new()) if $!o + $inc > $!expect;
            fail(X::Sum::Missing.new()) if $!expect < $!o + $inc;
        }
        $!o += $inc;

        # We took care of the length increment already.
        $!ignore_block_inc = True;

	if (!$justify) {
            @bcat.push(@firstpad);
	}
	else {
	    my @pad = @firstpad;
	    @bcat.splice(* div 8 * 8, 0,
                (False xx (8 - @bcat % 8 - @pad)),
# This should just be:
#	         @pad.splice(0, min(8 - @bcat % 8, *-0)).reverse
#... but it complains about "Code object coerced to string"
	         @pad.splice(0, min(8 - @bcat % 8, +@pad)).reverse
            );
	    # Rest of this block is conjectural
	    while (+@pad > 8) {
	        @bcat.push(reverse(@pad.splice(0,8)));
	    }
	    @bcat.push(False xx (8 - @pad), @pad.reverse) if @pad;
	}


        my $padbits = ($bbytes * 16 - $block.elems * 8 - $lenshifts.elems * 8
                       - @bcat - @lastpad);
        $padbits -= $bbytes * 8 if $padbits >= $bbytes * 8;

        @bcat.push(False xx $padbits);
        @bcat.push(@lastpad);
        my @bytes = (gather while +@bcat { take :2[@bcat.splice(0,8)] });

        my @vals = ($block[], @bytes, (255 X+& ($!o X+> (flat $lenshifts[ ]))));
        self.add(buf8.new(@vals[^$bbytes]));
        self.add(buf8.new(@vals[$bbytes .. *-1])) if +@vals > $bbytes;

        $.final = True;
    }
}

=AUTHOR Brian S. Julin

=COPYRIGHT Copyright (c) 2012 Brian S. Julin. All rights reserved.

=begin LICENSE
This program is free software; you can redistribute it and/or modify
it under the terms of the Perl Artistic License 2.0.
=end LICENSE

=SEE-ALSO C<Sum::(pm3)>

