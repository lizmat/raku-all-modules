use v6.c;
unit class P5each:ver<0.0.2>;

proto sub each(|) is export {*}
multi sub each(%hash is raw) {
    role EachHash {
        has @.the-keys;
        method INIT() { @!the-keys = self.keys; self }
        method each() {
            @!the-keys
              ?? ((my $key := @!the-keys.shift), self.AT-KEY($key))
              !! Empty
        }
    }
    %hash ~~ EachHash
      ?? %hash.each
      !! (%hash does EachHash).INIT.each
}

multi sub each(@array is raw) {
    role EachArray {
        has int $.index;
        method INIT() { $!index = -1; self }
        method each() {
            ++$!index < self.elems
              ?? ($!index, self.AT-POS($!index))
              !! Empty
        }
    }
    @array ~~ EachArray
      ?? @array.each
      !! (@array does EachArray).INIT.each
}

=begin pod

=head1 NAME

P5each - Implement Perl 5's each() built-in

=head1 SYNOPSIS

  use P5each;

=head1 DESCRIPTION

This module tries to mimic the behaviour of the C<each> of Perl 5 as closely as
possible.

=head1 PORTING CAVEATS

Using list assignments in C<while> loops will not work, because the assignment
will happen anyway even if an empty list is returned, so that this:

    while (($key, $value) = each %hash) { }

will loop forever.  There is unfortunately no way to fix this in Perl 6 module
space at the moment.  But a slightly different syntax, will work as expected:

    while each(%hash) -> ($key,$value) { }

Also, this will alias the values in the list, so you don't actually need to
define C<$key> and C<$value> outside of the `while` loop to make this work.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/P5each . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

Re-imagined from Perl 5 as part of the CPAN Butterfly Plan.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
