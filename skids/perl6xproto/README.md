perl6xproto
========

X::Protocol:: Perl 6 modules for protocol exceptions

## Purpose

The X::Protocol superclass is a convenience for working with status results
in protocol code.  Other than the quick subclass creation with sensible
defaults, the primary convenience is the ability to smartmatch against
terse Str and Numeric literals, or against regular expressions.

Beyond that, the X::Protocol module repo serves as a place for
protocol-specific subclasses so that long lists of human-readable
error messages can be shared by different protocol implementations.

More finicky features are also available.  See the embedded pod.

## Idioms

    The most common use will be something like:

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
    }

    {
        # stuff
        X::Protocol::BoxTruckOfFlashDrives.new(:status($result)).throw;
        # more stuff
        CATCH {
            when 300 { plug_lots_of_flash_drives_in(); }
            when 100 { get_gas(); $_.resume }
            when 200 { }
        }
    }