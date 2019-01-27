use v6.c;

# Since we cannot export a proto sub trait_mod:<is> with "is export", we
# need to do this manually with an EXPORT sub.  So we create a hash here
# to be set in compilation of the mainline and then return that in the
# EXPORT sub.
my %EXPORT;

# Save the original trait_mod:<is> candidates, so we can pass on through
# all of the trait_mod:<is>'s that cannot be handled here.
BEGIN my $original_trait_mod_is = &trait_mod:<is>;

module Array::Circular:ver<0.0.1>:auth<cpan:ELIZABETH> {

    role circular[\size] {
        method append(|) {
            callsame;
            self.shift until self.elems <= size;
        }
        method prepend(|) {
            callsame;
            self.shift until self.elems <= size;
        }
        method push(|) {
            callsame;
            self.shift until self.elems <= size;
        }
        method unshift(|) {
            callsame;
            self.pop until self.elems <= size;
        }
    }

    # Manually mark this proto for export
    %EXPORT<&trait_mod:<is>> := proto sub trait_mod:<is>(|) {*}

    # Handle the "is restricted" / is restricted(Bool:D) cases
    multi sub trait_mod:<is>(Variable:D \v, :$circular!) {
        if $circular.Int -> \size {
            my $name = v.var.name;
            trait_mod:<does>(v, circular[size]);
            v.var.WHAT.^set_name("$name\[{size},circular]");
        }
    }

    # Make sure we handle all of the standard traits correctly
    multi sub trait_mod:<is>(|c) { $original_trait_mod_is(|c) }
}

sub EXPORT { %EXPORT }

=begin pod

=head1 NAME

Array::Circular - add "is circular" trait to Arrays

=head1 SYNOPSIS

  use Array::Circular;

  my @a is circular(3);  # limit to 3 elements

=head1 DESCRIPTION

This module adds a C<is circular> trait to C<Arrays>.  This limits the size
of the array to the give number of elements, similar to shaped arrays.
However, unlike shaped arrays, you B<can> C<push>, C<append>, C<unshift>
and C<prepend> to arrays with the C<is circular> trait.  Then, if the
resulting size of the array is larger than the given size, elements will
be removed "from the other end" until the array has the given size again.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Array-Circular .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
