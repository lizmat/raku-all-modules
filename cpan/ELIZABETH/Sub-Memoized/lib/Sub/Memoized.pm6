use v6.c;

# Since we cannot export a proto sub trait_mod:<is> with "is export", we
# need to do this manually with an EXPORT sub.  So we create a hash here
# to be set in compilation of the mainline and then return that in the
# EXPORT sub.
my %EXPORT;

# Save the original trait_mod:<is> candidates, so we can pass on through
# all of the trait_mod:<is>'s that cannot be handled here.
BEGIN my $original_trait_mod_is = &trait_mod:<is>;

module Sub::Memoized:ver<0.0.3>:auth<cpan:ELIZABETH> {

    # Create the identification string for the capture to serve as key
    my sub fingerprint(Capture:D $capture --> Str:D) {
        my str @parts = $capture.list.map: *<>.WHICH.Str;
        @parts.push('|');  # don't allow positionals to bleed into nameds
        for $capture.hash -> $pair {
            @parts.push( $pair.key );  # key is always a string with nameds
            @parts.push( $pair.value<>.WHICH.Str );
        }
        @parts.join('|')
    }

    # Perform the actual wrapping of the sub to have it memoized
    my sub memoize(\r, \cache --> Nil) {
        r.wrap(-> |c {
            my $key := fingerprint(c);
            cache.EXISTS-KEY($key)
              ?? cache.AT-KEY($key)
              !! cache.BIND-KEY($key,callsame);
        });
    }

    # Manually mark this proto for export
    %EXPORT<&trait_mod:<is>> := proto sub trait_mod:<is>(|) {*}

    # Handle the "is memoized" / is memoized(Bool:D) cases
    multi sub trait_mod:<is>(Sub:D \r, Bool:D :$memoized! --> Nil) {
        if $memoized {
            my $name = r.^name;
            memoize(r, {});
            r.WHAT.^set_name("$name\(memoized)");
        }
    }

    # Handle the "is memoized(my %h)" case
    multi sub trait_mod:<is>(Sub:D \r, Hash:D :$memoized! --> Nil) {
        my $name = r.^name;
        memoize(r, $memoized<>);
        r.WHAT.^set_name("$name\(memoized)");
    }

    # Make sure we handle all of the standard traits correctly
    multi sub trait_mod:<is>(|c) { $original_trait_mod_is(|c) }
}

sub EXPORT { %EXPORT }

=begin pod

=head1 NAME

Sub::Memoized - trait for memoizing calls to subroutines

=head1 SYNOPSIS

  use Sub::Memoized;

  sub a($a,$b) is memoized {
      # do some expensive calculation
  }

  sub b($a, $b) is memoized( my %cache ) {
      # do some expensive calculation with direct access to cache
  }

  use Hash::LRU;
  sub c($a, $b) is memoized( my %cache is LRU( elements => 2048 ) ) {
      # do some expensive calculation, keep last 2048 results returned
  }

=head1 DESCRIPTION

Sub::Memoized provides a C<is memoized> trait on C<Sub>routines as an easy
way to cache calculations made by that subroutine (assuming a given set of
input parameters will always produce the same result).

Optionally, you can specify a hash that will serve as the cache.  This
allows later access to the generated results.  Or you can specify a specially
crafted hash, such as one made with C<Hash::LRU>.

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/Sub-Memoized . Comments and
Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod

# vim: ft=perl6 expandtab sw=4
