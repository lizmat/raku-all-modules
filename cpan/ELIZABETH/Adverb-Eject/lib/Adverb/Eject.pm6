use v6.c;

module Adverb::Eject:ver<0.0.1>:auth<cpan:ELIZABETH> {
    multi sub postcircumfix:<[ ]>(
      \SELF, Int() $pos, :$eject! --> Nil
    ) is export {
        SELF.splice($pos,1) if $eject;
    }
    multi sub postcircumfix:<[ ]>(
      \SELF, Iterable:D \pos, :$eject! --> Nil
    ) is export {
        if $eject {
            SELF.splice($_,1) for pos.unique.sort( -* );
        }
    }

    multi sub postcircumfix:<{ }>(
      \SELF, \key, :$eject! --> Nil
    ) is export {
        SELF.DELETE-KEY(key) if $eject;
    }
    multi sub postcircumfix:<{ }>(
      \SELF, Iterable:D \keys, :$eject! --> Nil
    ) is export {
        if $eject {
            SELF.DELETE-KEY($_) for keys;
        }
    }
}

=begin pod

=head1 NAME

Adverb::Eject - adverb for ejecting elements

=head1 SYNOPSIS

  use Adverb::Eject;

  my @a = ^10;
  @a[1]:eject; # does *not* return the removed value
  say @a;      # 0 2 3 4 5 6 7 8 9
  @a[1,3,5,7]:eject;
  say @a;      # 0 3 5 7 9

  my %h = a => 42, b => 666, c => 371;
  %h<a>:eject;
  say %h;      # {b => 666, c => 371};
  %h<b c>:eject;
  say %h;      # {}

=head1 DESCRIPTION

This module adds the C<:eject> adverb to C<postcircumfix []> and
C<postcircumfix { }>.  It will remove the indicated elements from
the object they're called on (usually an C<Array> or a C<Hash>) and
always return C<Nil>, whether something was removed or not.

For C<Hash>es, this is similar to the C<:delete> adverb, except that it will
B<not> return the values that have been removed.

For C<Array>s, this is B<also different> from the C<:delete> adverb in that
it will actually B<remove> the indicated element from the C<Array> (as opposed
to just resetting the element to its pristine state).

The reason that the C<:eject> adverb does not return any of the removed values
is because the C<:delete> already does that.  And for those cases where you
do not need the values, the C<:eject> adverb has the potential of being more
efficient because it wouldn't have to do the work of producing the values.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Adverb-Eject . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
