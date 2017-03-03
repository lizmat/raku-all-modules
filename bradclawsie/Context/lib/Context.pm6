use v6;

=begin pod

=head1 NAME

Context: A building block for concurrent programming based on Go's `context`.

=head1 DESCRIPTION

Go's `context` (https://golang.org/pkg/context/) solves two important problems
for concurrent programming. First, it provides a mechanism for sharing a safe
cancellation mechanism. Second, it provides a safe abstraction for sharing
values between concurrent execution contexts.

Consider a program which spawns workers concurrently but then wants to terminate
them. The Context package provides a standard building block for providing this.

Now assume the same program encodes values into some protocol mechanism such
as HTTP headers or query parameters for spawned workers to access. The problem
with this is it results in brittleness; if a developer wishes to move some
value from a query parameter to a header, they must chase down every piece
of code that works thusly and edit it. The better approach is to eliminate
protocol details as early in the process of spawning workers entirely, and to
use a protocol-agnostic mechanism like a Context instance to communicate these
values safely to spawned workers.

It is often good practice to not make assumptions about the concurrent environment
library code will be used in, but the Context package only makes sense as a
building block for concurrent development, so it is enabled for safe use
in concurrent environments by default. Context is not recommended as a way
of passing persistent references like DB connection handles etc, instead
it is recommended that Context only be used for request-scope values.

Like the Go equivalent, this library doesn't reduce keystrokes. Indeed, it
increases keystrokes as it implies adopting a new pattern for concurrent
development. 

=head1 SYNOPSIS

See `examples`.

=head1 AUTHOR

Brad Clawsie (PAUSE:bradclawsie, email:brad@b7j0c.org)

=head1 LICENSE

This module is licensed under the BSD license, see: https://b7j0c.org/stuff/license.txt

=end pod

class X::Context::KeyNotFound is Exception is export {
    has Mu $.key;
    method message() { 'not found: ' ~ $.key.gist; }
}

# The supply for Context may send other consumables. This is the one you should exchange
# when you want to cancel a context.
constant $CONTEXT_CANCEL is export = 'context-cancel';

class Context:auth<bradclawsie>:ver<0.0.1> is export {
    has Hash[Mu,Any] $!kv;
    has Lock $!lock;
    has Supplier $.supplier;
    
    submethod BUILD() {
        $!kv = Hash[Mu,Any].new();
        $!lock = Lock.new();
        $!supplier = Supplier.new();
    }
    
    # `set` a key/value in the shared hash. The value will be cloned unless
    # an optional make-copy function of Any --> Any is provided, in which
    # case it will be called.
    method set(Mu:D $key, Any $val, Sub $make-copy?) {
        my $block = {
            my Any $copy = $make-copy.defined ?? $make-copy($val) !! $val.clone;
            $!kv.append(:{($key) => $copy});
        }
        $!lock.protect($block);
    }
    
    # `get` a value in the shared hash. The value will be cloned unless
    # an optional make-copy function of Any --> Any is provided, in which
    # case it will be called. An exception of type X::Context::KeyNotFound
    # is thrown upon a key not being set in the shared hash.
    method get(Mu:D $key, Sub $make-copy? --> Any) {
        my $block = {
            if $!kv{$key}:exists {
                my Any $val = $!kv{$key};
                return $make-copy.defined ?? $make-copy($val) !! $val.clone;
            } else {
                X::Context::KeyNotFound.new(key=>$key).throw;
            }
        }
        $!lock.protect($block);
    }
    
    # `canceler` returns a sub you can call to force the context to canel.
    method canceler(--> Sub) {
        return sub {
            $!supplier.emit($CONTEXT_CANCEL);
        }
    }

    # Potential future support could include timed cancelers...
}
