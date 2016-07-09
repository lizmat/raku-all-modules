# EuclideanRhythm

Implementation of the algorithm described in http://cgm.cs.mcgill.ca/~godfried/publications/banff.pdf

[![Build Status](https://travis-ci.org/jonathanstowe/EuclideanRhythm.svg?branch=master)](https://travis-ci.org/jonathanstowe/EuclideanRhythm)

## Synopsis

```perl6

    use EuclideanRhythm;

    my $r = EuclideanRhythm.new(slots => 16, fills => 7);

    for $r.list {
        # do something if the value is True
    }
```

## Description


This provides an implementation of the algorithm described in
[http://cgm.cs.mcgill.ca/~godfried/publications/banff.pdf](http://cgm.cs.mcgill.ca/~godfried/publications/banff.pdf)
which is in turn derived from a Euclidean algorithm. Simply put it
provides a simple method to distribute a certain number of "fills"
(hits, beats, notes or whatever you want to call them,) as evenly as
possibly among a number of "slots". The linked paper describes how, using
this method, you can approximate any number of common rhythmic patterns
(as well as not so common ones.)

You could of course use it for something other than generating musical
rhythms: any requirement where a number of events need to be distributed
over a fixed number of slots may find this useful.

## Installation

Assuming you have a working installation of Rakudo perl 6 then you
should be able to install this with:

	panda install EuclideanRhythm

or if you have a local copy of this repository:

	panda install .

in the directory you found this file.

I haven't tested it but I see no reason that this shouldn't work
equally as well with "zef" or some similarly capable package manager.

## Support

This is a fairly simple module such that the scope for any
egregious bugs is quite limited, however if you have any
suggestions, patches or comment the feel free to leave a post at
https://github.com/jonathanstowe/EuclideanRhythm/issues.

Because it is quite simple in both scope and implementation I would
anticipate that any higher level functionality (such as providing timing,)
would be implemented in another module.

## Licence and Copyright

This is free software. Please see the LICENCE file in the distribution.

© Jonathan Stowe 2016

