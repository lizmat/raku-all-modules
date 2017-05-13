# Concurrent::BoundedChannel

The normal perl6 Channel is an unbounded queue.  This subclass offers
an alternative with size limits.

## Synopsis

    use Concurrent::BoundedChannel;

    # Construct a BoundedChannel with 20 entries
    my $bc = BoundedChannel.new(limit=>20);

    $bc.send('x');          # will block if $bc is full
    my $val = $bc.receive;  # returns 'x'

    my $oval=$bc.offer('y');  # non-blocking send - returns the offered value
                              # ('y' in this case), or Nil if $bc is full

    $val=$bc.poll;

    $bc.close;

    # OR

    $bc.fail(X::SomeException.new);

## Overview

The normal Perl 6 Channel class is an unbounded queue.  It will grow
indefinitely as long as values are fed in and not removed.  In some cases
that may not be desirable.  BoundedChannel is a subclass of Channel
with a set size limit.  It behaves just like Channel, with some exceptions:

* The send method will block, if the Channel is already populated with
the maximum number of elements.
* There is a new offer method, which is the send equivalent of poll - i.e. a
non-blocking send.  It returns Nil if the Channel is full, otherwise it
returns the offered value.
* If one or more threads is blocking on a send, and the channel is closed,
those send calls will throw exceptions, just as if send had been called on
a closed normal Channel.

The fail method is an exception to the BoundedChannel limit.  If the
BoundedChannel is full, and fail is called, the exception specified will
still be placed at the end of the queue, even if that would violate
the limit.  This was deemed acceptable to avoid having a fail contend with
blocking send calls.

## BoundedChannel

The constructor takes one parameter (limit), which can be anwhere from
zero to as large as you wish.  A zero limit BoundedChannel behaves similar
to a UNIX pipe - a send will block unless a receive is already waiting for
value, and a receive will block unless a send is already waiting.
