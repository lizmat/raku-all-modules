
use v6;

unit module Memoize;

# This is called when 'is memoized' is added to a routine that returns a result
multi sub trait_mod:<is>(Routine $r, :$memoized!) is export {
  my %cache;
  my $options            = ($memoized ~~ Pair) || ($memoized ~~ List)
    ?? $memoized.hash
    !! {};
  my Int $cache_size     = $options<cache_size>     // 1000;
  my Str $cache_strategy = $options<cache_strategy> // "LRU";
  my Bool $pure          = $options<pure>           // True;
  my Bool $debug         = $options<debug>          // False;

  die if $cache_strategy ne "LRU";

  if $pure {
    # Guarantee that 'is pure' is applied (if enabled)
    # Memoization guarantees by definition the function pureness
    my Bool $is-pure = False;
    {
      $is-pure = $r.IS_PURE;
      CATCH { default { } }
    }
    unless $is-pure {
      # Mixin 'is pure' for impure
      $r.^mixin( role {
        method IS_PURE { True }
      });
    }
  }

  # Wrap the routine in a block that..
  $r.wrap(-> $arg {

    # looks up the argument in the cache
    my $result;
    if %cache{$arg}:exists {
      # On cache hit, returns the routine result
      say sprintf("Cache hit on '%s'!", $arg) if $debug;

      my $o = %cache{$arg};
      $result = $o<result>;
      $o<count>++;

    } else {
      # On cache miss, it calls the original routine
      say sprintf("Cache miss on '%s'!", $arg) if $debug;

      $result = callwith($arg);
      %cache{$arg} = %(
        :result($result),
        :count(0)
      );

      if %cache.elems >= $cache_size {
        # Evict least recent used (LRU) element
        #TODO Eviction should be done if needed in another thread every N seconds
        my @results = %cache.sort( { $^a.value<count> cmp $^b.value<count> } );
        my $lru = @results[0];
        say sprintf("Evicting %s\('%s') used only %d time(s), cache_size=%d ", $r.name, $lru.key, $lru.value<count>, $cache_size) if $debug;
        %cache{$lru.key}:delete;
      }
    }

    $result;
  });
}


=begin pod

=head1 NAME

Memoize - Make routines faster by trading space for time

=head1 SYNOPSIS

=begin code

use v6;
use Memoize;

sub get-slowed-result(Int $n where $_ >= 0) is memoized {
  sleep $n / 10;
  return 1 if $n <= 1;
  return get-slowed-result($n - 1) * $n;
}

say sprintf("get-slowed-result(%d) is %d", $_, get-slowed-result($_)) for 0..10;

=end code

=head1 DESCRIPTION

This make a Perl 6 routine faster by caching its results. This means it trades
more memory space used to get less execution time on cache hits. This means it is 
faster on routines that return a result such the following:

=item An expensive calculation (CPU)
=item A slow database query (I/O)

This is a totally-experimental-at-the-moment module to create a subroutine trait
similar to the currently experimental `is cached`.

=head1 OPTIONS

=item cache_size - Int (Default: 1000)

Define the cache size limitation on which cache eviction will occur. A bigger
cache means faster.

=item strategy - Str (Default: LRU)

Define the cache eviction strategy. Only LRU (least recently used) is currently
allowed.

=item pure - Bool (Default: True)

When this is enabled, L<is pure|http://doc.perl6.org/routine/is%20pure> is
implied on any 'is memoized' wrapped routine.

=item debug - Bool (Default: False)

Enable or disables verbose debugging. Not recommended to be True in production
enviroments.

=head1 SEE ALSO

=item L<Add memoize to Perl 6 Most Wanted|https://github.com/perl6/perl6-most-wanted/pull/20>
=item L<Memoize (CPAN)|https://metacpan.org/pod/Memoize>
=item L<Memoize::ExpireLRU (CPAN)|https://metacpan.org/pod/Memoize::ExpireLRU>
=item L<Perl 6 RFC 228 - Add memoize into the standard library|http://perl6.org/archive/rfc/228.html>
=item L<Design specification for `is cached` subroutine trait|http://design.perl6.org/S06.html#is_cached>
=item L<Perl 6 documentation for `is cached` subroutine trait|http://doc.perl6.org/routine/is%20cached>
=item L<Memoization on Wikipedia|https://en.wikipedia.org/wiki/Memoization>
=item L<Pure and impure functions on Wikipedia|https://en.wikipedia.org/wiki/Pure_function#Impure_functions>

=end pod
