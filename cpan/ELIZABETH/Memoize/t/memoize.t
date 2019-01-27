use v6.c;
use Test;

use Memoize <memoize unmemoize flush_cache>;

plan 20;

my $size = 100;
my $times = 10;

# basic, by string
{
    my @seen;
    sub a($a) { ++@seen[$a]; $a };

    my $original = &a.^name;
    isnt memoize('a').^name, $original,
      'did the memoization change the sub with default normalizer';

    for ^$times {
        a($_) for (^$size).pick(*);
    }
    is-deeply @seen, [1 xx $size],
      'was each different value only seen once with default normalizer';

    is unmemoize('a').^name, $original,
      'did the unmemoization restore the sub with default normalizer';

    lives-ok { flush_cache('a') }, 'can we flush the cache ok';
}

# basic, by code object
{
    my @seen;
    sub a($a) { ++@seen[$a]; $a };

    my $original = &a.^name;
    isnt memoize(&a).^name, $original,
      'did the memoization change the sub with default normalizer';

    for ^$times {
        a($_) for (^$size).pick(*);
    }
    is-deeply @seen, [1 xx $size],
      'was each different value only seen once with default normalizer';

    is unmemoize(&a).^name, $original,
      'did the unmemoization restore the sub with default normalizer';

    is &a.cache.elems, $size, 'did we get see all the values';
    flush_cache(&a);
    is &a.cache.elems, 0, 'did we all the values get removed';
}

# specific normalizer, code object
{
    my @seen;
    my $normalized;
    sub a($a) { ++@seen[$a]; $a };

    my $original = &a.^name;
    isnt memoize(&a, NORMALIZER => -> \c { ++$normalized; c.gist }).^name,
      $original,
      'did the memoization change the sub with given normalizer';

    for ^$times {
        a($_) for (^$size).pick(*);
    }
    is $normalized, $times * $size, "did the normalizer get called";
    is-deeply @seen, [1 xx $size],
      'was each different value only seen once with given normalizer';
}

# in memory cache, by code object
{
    my @seen;
    sub a($a) { ++@seen[$a]; $a };

    my $original = &a.^name;
    isnt memoize(&a, :CACHE<MEMORY>).^name,
      $original,
      'did the memoization change the sub';

    for ^$times {
        a($_) for (^$size).pick(*);
    }
    is-deeply @seen, [1 xx $size],
      'was each different value only seen once';
}

# in memory multi cache, by code object
{
    my @seen;
    sub a($a) { ++@seen[$a]; $a };

    my $original = &a.^name;
    isnt memoize(&a, :CACHE<MULTI>).^name,
      $original,
      'did the memoization change the sub';

    await do for ^$times { start {
        for ^$size {
            sleep rand / 100;
            a($_)
        }
    } }
    is-deeply [@seen.map: *.Bool], [True xx $size],
      'was each different value only seen at least once';
}

# with specific cache, by code object
{
    my $flushed;
    role Flush { method FLUSH() { ++$flushed } }

    my @seen;
    sub a($a) { ++@seen[$a]; $a };

    my $original = &a.^name;
    isnt memoize( &a, :CACHE(my %hash does Flush)).^name,
      $original,
      'did the memoization change the sub';

    for ^$times {
        a($_) for (^$size).pick(*);
    }
    is-deeply @seen, [1 xx $size],
      'was each different value only seen once';

    is unmemoize(&a).^name, $original,
      'did the unmemoization restore the sub with default normalizer';
    ok $flushed, 'did we actually call FLUSH';
}

# vim: ft=perl6 expandtab sw=4
