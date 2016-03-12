Perl6-Control-Bail
========

Control::Bail:: Perl 6 module for deferred error cleanup

## Purpose

The Control::Bail module allows nested allocations of resources to be
released in an orderly fashion, without repeating yourself, with no deep
block nesting and with deallocation code placed next to the corresponding
allocation code.

Remember this from your C days?

```C
thing *allocthing() {
    thing *res = malloc(sizeof(struct thing));
    if (!thing) goto bail0;
    thing.foo = malloc(sizeof(struct thing2));
    if (!thing.foo) goto bail1;
    thing.foo = malloc(sizeof(struct thing2));
    if (!thing.foo.bar) goto bail2;
    return thing;
bail2:
    free(thing.foo);
bail1:
    free(thing);
bail0:
    fprintf(stderr, "Error allocating thing");
    return NULL;
} 
```

...While this had the advantage of avoiding deeply nested if/else
blocks, the code for freeing a resource was visually separated from
the code for allocating it.  The other option was to make your
deallocators smart enough to realize when they were passed a partially
constructed object, so you could call it from the constructor
on error:

```C
void freething(thing *) {
    if (thing.foo.bar) free thing.foo.bar;
    if (thing.foo) free thing.foo;
    if (thing) free thing;
}
```

All in all that was not a horrible thing, and these days with GC we
often do not have to even bother with manual allocations -- but for
resources other than memory that need to be cleaned up quickly, like
TCP network connections, some languages have a construct, for example,
go's "defer" (example stolen from rosettacode:)

```go
import "os"
 
func processFile() {
    f, err := os.Open("file")
    if err != nil {
        // (probably do something with the error)
        return // no need to close file, it didn't open
    }
    defer f.Close() // file is open.  no matter what, close it on return
    var lucky bool
    // some processing
    if (lucky) {
        // f.Close() will get called here
        return
    }
    // more processing
    // f.Close() will get called here too
}
```

...which can help a lot, but you'd have to add tests to prevent the
deallocation from happening if you wanted to return the allocated object
from the function.

In Perl 6 there is a similar stack of "things that run after a function
returns" through the LEAVE/KEEP/UNDO phasers.  These all exist on the same
queue (the LEAVE queue) but the KEEP and UNDO variety allow you to cancel
them by the way you return from the block.  This is nice.  However, unlike
defer, they are found and attached to the block at compile time:

```perl6
sub makething () {
   LEAVE { 42.say };
   return "thing";
   LEAVE { 43.say };
}
makething(); # Says 43 and then says 42.
```

In the above, even though the return "happens before" the second LEAVE block
visually, that LEAVE block still runs.  So you still have to test whether
something has been done before trying to undo it.

This module solves that problem by providing a run-time version of these
phasers which works the way go's "defer" works -- it does not install the
cleanup code unless the flow of control actually reaches the statement.
The "bail", "trail", and "trail-keep" map to UNDO, LEAVE, and KEEP,
respectively.

## Status

Brand spanking new.  The names of the provided functions may end up
being capitalized or perhaps changed entirely.  Let the bikeshedding
commence.  Also, this module uses a lot of metamodel/internal stuff that
is not necessarily nailed down by specification, so it cannot promise
the same stability as one that uses only the tested 6.c features.

## Idioms

```perl6
# This DWYW.  No need to test $skel or $thing to see whether or
# not they were allocated, works in reverse order of bail statements,
# and no bail statements get run when successful.
sub make_thing {
    my $skel = make_skeleton();
    $skel or die "Could not make skeleton";
    bail { destroy_skeleton($skel); }

    my $thing = make_skin($skel);
    $thing or die "Could not make skin";
    bail { destroy_skin($thing); }

    Bool.pick or die("Unpredicable failure");
    $thing;
}

# In the following code:
# If there was a touchdown there is cheering
# ...then...
# The Receiver gets an icepack, but only if he was tackled.
# ...then...
# The Receiver always gets juice, unless the QB was sacked.
# ...then...
# The QB always gets taunted, unless there was a touchdown.
# ...then...
# If there was no touchdown, the failure is thrown.
use Control::Bail;
sub towlboy {
    bail { say "Taunt the QB" }
    Bool.pick or die "sacked!";
    trail { say "Bring Receiver juice" }
    bail { say "Bring Receiver icepack" }
    Bool.pick or die "tackled!";
    say "touchdown!";
}
towlboy();
```
