[![Build Status](https://travis-ci.org/chsanch/perl6-Lingua-Stem-Es.svg?branch=master)](https://travis-ci.org/chsanch/perl6-Lingua-Stem-Es)

# NAME
Lingua::Stem::Es - Porter's steming algorithm for Spanish

# SYNOPSIS

```perl6
    use Lingua::Stem::Es

    my $stem = stem( $word );

```

# DESCRIPTION

This module uses Porter's Stemming Algorithm to return a stemmed word.
The algorithm is implemented as described in: [http://snowball.tartarus.org/algorithms/spanish/stemmer.html](http://snowball.tartarus.org/algorithms/spanish/stemmer.html) 

# REPOSITORY

Fork this module on GitHub:

[https://github.com/chsanch/perl6-Lingua-Stem-Es](https://github.com/chsanch/perl6-Lingua-Stem-Es)

# BUGS

To report bugs or request features, please use:

[https://github.com/chsanch/perl6-Lingua-Stem-Es/issues](https://github.com/chsanch/perl6-Lingua-Stem-Es/issues)

# AUTHOR

This module was inspired by Perl 5's module [Lingua::Stem::Es](https://metacpan.org/pod/Lingua::Stem::Es).

Christian Sánchez <chsanch@cpan.org>.

# LICENSE

You can use and distribute this module under the terms of the
The Artistic License 2.0. See the `LICENSE` file included in this
distribution for complete details.

The `META6.json` file of this distribution may be distributed and modified
without restrictions or attribution.
