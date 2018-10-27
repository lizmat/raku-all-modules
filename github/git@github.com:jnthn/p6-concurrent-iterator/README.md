# Concurrent::Iterator

[![Build Status](https://travis-ci.org/jnthn/p6-concurrent-iterator.svg?branch=master)](https://travis-ci.org/jnthn/p6-concurrent-iterator)

A standard Perl 6 `Iterator` should only be consumed from one thread at a time.
`Concurrent::Iterator` allows any Iterable to be iterated concurrently.

## Synopsis

    use Concurrent::Iterator;

    # Make a concurrent iterator over an infinite Range of ascending
    # integers.
    my $ids = concurrent-iterator(0..Inf);

    # Many concurrent workers can use it to obtain the IDs, being confident
    # of no duplication.
    do await for ^10 {
        start {
            say "I got $ids.pull-one()";
        }
    }

## Overview

The purpose of `Concurrent::Iterator` is to allow multiple threads to safely
race to obtain values from a single iterable source of data. It:

* Uses locking to ensure that only one thread can be pulling a value from the
  underlying iterator at a time
* Will return `IterationEnd` to all future requests for values after it is
  returned by the underlying iterator (it is erroneous to call pull-one on
  a normal Iterator that has already produced `IterationEnd`)
* Will rethrow any exception thrown by the underlying iterator on all future
  requests

Together, these mean that it is possible to use a `Concurrent::Iterator` to have
many workers compete for data items to process, and have them all terminate on
end of sequence or exception. That might look something like this

    my \to-process = concurrent-seq(@data);
    my @results = flat await do for ^4 {
        start (compute-stuff($_) for to-process)
    }

However, there's no reason to use Concurrent:Iterator for such a simple use
case. It is far more simply expressed without this module as just:

    my @results = @data.hyper.map(&compute-stuff);

Or, if you really wanted to enforce one-at-a-time and exactly 4 workers:

    my @results = @data.hyper(:degree(4), :batch(1)).map(&compute-stuff);

## Concurrent::Iterator

The `Concurrent::Iterator` class is constructed with a single positional
argument, which must be of type `Iterable:D`:

    my $ci = Concurrent::Iterator.new(1..Inf);

It implements the Perl 6 standard `Iterator` interface.

## Convenience subs

There is a convenience sub to form a `Concurrent::Iterator`:

    my $ci = concurrent-iterator(1..Inf);

There is also one to have it wrapped in a `Seq`:

    my $cs = concurrent-seq(1..Inf);

Which literally just passes the result of calling `concurrent-iterator` to
`Seq.new`.
