# TITLE

Algorithm::LCS

# SYNOPSIS

```perl6
  use Algorithm::LCS;

   # regular usage
   say lcs(<A B C D E F G>, <A C F H J>); # prints T<A C F>

   # custom comparator via :compare
   say lcs(<A B C>, <D C F>, :compare(&infix:<eq>));

   # extra special custom comparison via :compare-i
   my @a        = slurp('one.txt'); 
   my @b        = slurp('two.txt'); 
   my @a-hashed = @a.map({ hash-algorithm($_) });
   my @b-hashed = @b.map({ hash-algorithm($_) });
   say lcs(@a, @b, :compare-i({ @a-hashed[$^i] eqv @b-hashed[$^j] }));
```

# DESCRIPTION

This module contains a single subroutine, lcs, that calculates the longest common subsequence between two sequences of data. lcs takes two lists as required parameters; you may also specify the comparison function (which defaults to eqv) via the &compare named parameter). Sometimes you may want to maintain a parallel array of information to consult during calculation (for example, if you're comparing long lines of a file, and you'd like a speedup by comparing their hashes rather than their contents); for that, you may use the &compare-i named parameter.

# SEE ALSO

http://en.wikipedia.org/wiki/Longest_common_subsequence_problem
