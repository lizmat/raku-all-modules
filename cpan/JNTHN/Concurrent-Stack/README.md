# Concurrent::Stack

A lock-free stack data structure, safe for concurrent use.

## Synopsis

    use Concurrent::Stack;

    my $stack = Concurrent::Stack.new;

    for 'a'..'z' {
        $stack.push($_);
    }

    say $stack.elems;       # 26
    say $stack.peek;        # z
    say $stack.pop;         # z
    say $stack.pop;         # y
    say $stack.peek;        # x
    $stack.push('k');
    say $stack.peek;        # k
    say $stack.elems;       # 25

    $stack.pop for ^25;
    say $stack.elems;       # 0
    my $x = $stack.peek;    # Failure with X::Concurrent::Stack::Empty 
    my $y = $stack.pop;     # Failure with X::Concurrent::Stack::Empty

## Overview

Lock-free data structures may be safely used from multiple threads, yet do not
use locks in their implementation. They achieve this through the use of atomic
operations provided by the hardware. Nothing can make contention between
threads cheap - synchronization at the CPU level is still synchronization -
but lock free data structures tend to scale better.

This lock-free stack data structure uses a linked list of immutable nodes, the
only mutable state being a head pointer to the node representing the stack top
and an element counter mintained through atomic increment/decrement operations.
The element count updates are not performed as part of the stack update, and so
may lag the actual state of the stack. However, since checking the number of
elements to decide whether to `peek` or `pop` is doomed in a concurrent setting
anyway (since another thread may `pop` the last value in the meantime), this is
not problematic. The `elems` method primarily exists so that the number of
elements can be queried once the stack reaches some known stable point (for
example, when a bunch of working threads that `push` to it are all known to
have completed their work).

### Methods

#### push(Any $value)

Pushes a value onto the stack. Returns the value that was pushed.

#### pop()

If the stack is not empty, removes the top value and returns it. Otherwise,
returns a `Failure` containing an exception of type `X::Concurrent::Stack::Empty`.

#### peek()

If the stack is not empty, returns the top value. Otherwise, returns a `Failure`
containing an exception of type `X::Concurrent::Stack::Empty`.

#### elems()

Returns the number of elements on the stack. This value can only be relied upon
when it is known that no threads are pushing/popping from the stack at the
point this method is called. Never use the result of `elems` to decide whether
to `peek` or `pop`, since another thread may `pop` in the meantime. Instead,
check if `peek` or `pop` return a `Failure`.

#### Bool()

Returns `False` if the stack is empty and `True` if the stack is non-empty.
The result can only be relied upon when it is known that no threads are
pushing/popping from the stack at the point this method is called. Never use
the result of `Bool` to decide whether to `peek` or `pop`, since another
thread may `pop` in the meantime. Instead, check if `peek` or `pop` return a
`Failure`.
