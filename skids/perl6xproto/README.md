perl6xproto
========

X::Protocol:: Perl 6 modules for protocol exceptions


## Purpose

The X::Protocol superclass is a convenience for working with status results
in protocol code.  It allows one to reap the benefits of typed exceptions
without having to type out their names very often.  You simply feed the
error code from the protocol in as an argument to X::Protocol.new (or,
more usually, to a subclass) and it is automatically paired with a human
readable error message, producing an object that can be printed, thrown,
or inspected.

One can easily tell a protocol error apart from an internal code error
by whether it matches X::Protocol, and tell which protocol an error came
from either by looking at the .protocol attribute, or checking which
subclass it belongs to.

Better yet, you can simply smart match the object against integers, strings
and regular expressions in your error handling code.

For commonly used protocols, the X::Protocol module repository serves as a
place for protocol-specific subclasses to store long lists of human-readable
error messages so they can be shared by different protocol implementations
and maintained in one place.

More finicky features are also available.  See the embedded pod.


## Idioms

The most common use will be something like this in a module:

    class X::Protocol::BoxTruckOfFlashDrives is X::Protocol {
        method protocol { "BoxTruckOfFlashDrives" }
        method codes {
            {
                100 => "Out of gas";
                200 => "Petabytes per hour.  Beat that!";
                300 => "Now you have to plug them all in by hand";
                400 => "Hit a guard rail";
            }
        }
        method severity {
            when 200 { "success" };
            "error";
        }
    }

...and then the user of the module would do something like this:

    {
        # stuff that results in a status code in $result
        X::Protocol::BoxTruckOfFlashDrives.new(:status($result)).toss;
        # More stuff that happens if the exception is resumed or .toss
        # did not throw an exception.
        CATCH {
            when X::Protocol::BoxTruckOfFlashDrives {
                when 300 { plug_lots_of_flash_drives_in(); }
                when 100 { get_gas(); $_.resume }
            }
            # Handle other kinds of errors
        }
    }
