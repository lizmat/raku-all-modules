use v6;
use Context;

# In this example we show how one might adapt this pattern.
# The example illustrates how to spawn a concurrent routines
# and then both communicate with it and cancel it. 

# Note how the pattern implied by using Context results
# in some extra code required in a spawned routine in
# order to capture control messages from the Context
# instance.

# Also note that Contexts are intended to be instantiated
# per-request and it is recommended to only store transient
# request-scoped values; don't use it to store DB handles etc.

# Here is a contrived "client" that our main program will
# spawn, communicate with, and possibly cancel.
sub sample-client(Context:D $ctx) {

    # This supply is how the Context can request cancellation.
    my $supply = $ctx.supplier.Supply;

    # This supply is how we can signal completion inside this
    # spawned routine.
    my $our-supplier = Supplier.new();
    my $our-supply = $our-supplier.Supply;

    # Look for either a cancel message or our own completion
    # message.
    my $p = start {
        react {
            whenever $supply -> $v { # Context cancel supply.
                if $v eq $CONTEXT_CANCEL {
                    say "context supply:$v";
                    done;                    
                }
            }
            whenever $our-supply -> $v { # Local completion supply.
                say "our supply:$v";
                done;
            }
        }
    }

    # This is where the actual work of a spawned routine would be.
    start {

        # Some work to be done may require looking up
        # a value in the shared Context hash. This is
        # safe for both sides (caller and callee) to do.
        my $a-val;
        try {
            $a-val = $ctx.get('a');
            CATCH {
                when X::Context::KeyNotFound {
                    # We've deciced to exit if we can't find our value.
                    $our-supplier.emit('key not found');
                }
            }
            say "a val:" ~ $a-val;
        }

        # Let's assume our "work" takes two more seconds.
        # The caller will want to cancel at 1 second. You
        # can play with these values to change that.
        sleep 2;
        $our-supplier.emit(1);
    }    
    await $p;
}

# Create a new Context. Let's say that we spawn concurrent
# routines that read state values from various protocol
# attributes depending on the problem domain. By centralizing
# these keys/values in our Context object, we can abstract
# the particular protocol details away.
my $c = Context.new();
$c.set('a','b');
$c.set('c','d',sub (Str $s --> Str) { return $s.clone; });

# Get a cancel function which can be called at any time
# to request that a concurrent routine be cancelled. 
my $canceler = $c.canceler();

# Start the sample-client...maybe in the real world this
# is a web request handler in a framework.
my $p = start {
    sample-client $c;
}

# Sleep for a second and then decide that the sample-client
# needs to be asked to cancel.
start {
    sleep 1;
    $canceler();
}

await $p;
