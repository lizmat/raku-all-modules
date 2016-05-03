# Memoize

[![Build Status](https://travis-ci.org/azawawi/perl6-memoize.svg?branch=master)](https://travis-ci.org/azawawi/perl6-memoize) [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-memoize?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-memoize/branch/master)

This make a Perl 6 routine faster by caching its results. This means it trades
more memory space used to get less execution time on cache hits. This means it
is faster on routines that return a result such the following:
- An expensive calculation (CPU)
- A slow database query (I/O)

This is a totally-experimental-at-the-moment module to create a subroutine trait
similar to the currently experimental `is cached`.

## Plan

- Add None to strategy to disable cache eviction and cache size limitation
- Determine tunable cache size statistics
- Add a pluggable architecture to cache expiry.

> perlpilot: it would be interesting if you could pass the thing that handles the caching as a parameter, but perhaps only as an academic exercise.

## Example

```Perl6
use v6;
use Memoize;

sub get-slowed-result(Int $n where $_ >= 0) is memoized {
  sleep $n / 10;
  return 1 if $n <= 1;
  return get-slowed-result($n - 1) * $n;
}

say sprintf("get-slowed-result(%d) is %d", $_, get-slowed-result($_)) for 0..10;
```

## Memoize vs `is-cached`

- `is-cached` is currently marked as experimental as per a [#perl6 discussion](
http://irclog.perlgeek.de/perl6/2016-02-28#i_12114511).

Here is an example for `is cached` for the sake of completeness:

```Perl6
#!/usr/bin/env perl6

use v6;
use experimental :cached;

sub get-slowed-result(Int $n where $_ >= 0) is cached {
  sleep $n / 10;
  return 1 if $n <= 1;
  return get-slowed-result($n - 1) * $n;
}

say sprintf("get-slowed-result(%d) is %d", $_, get-slowed-result($_)) for 0..10;
```

## See Also
- [Add memoize to Perl 6 Most Wanted](https://github.com/perl6/perl6-most-wanted/pull/20)
- [Memoize (CPAN)](https://metacpan.org/pod/Memoize)
- [Memoize::ExpireLRU (CPAN)](https://metacpan.org/pod/Memoize::ExpireLRU)
- [Perl 6 RFC 228 - Add memoize into the standard library](http://perl6.org/archive/rfc/228.html)
- [Design specification for `is cached` subroutine trait](http://design.perl6.org/S06.html#is_cached)
- [Perl 6 documentation for `is cached` subroutine trait](http://doc.perl6.org/routine/is%20cached)
- [Memoization on Wikipedia](https://en.wikipedia.org/wiki/Memoization)
- [Pure and impure functions on Wikipedia](https://en.wikipedia.org/wiki/Pure_function#Impure_functions)

## Author

Ahmad M. Zawawi, azawawi on #perl6, https://github.com/azawawi/

## License

MIT License
