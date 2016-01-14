# perl6-Proc-Screen
Perl6 programmatic interface for manipulating GNU screen sesssions

## Status

This is in "release early" status.  Not even the ecosystem hooks
are done yet, but basic use of Proc::Screen may work.

## Proc::Screen

Proc::Screen currently allows you to silently create screen sessions
and send commands to them.  Eventually managing previously created
screen sessions and support for programmatic generation of screenrc
and screen commandlines is planned, but for now the main objective
is to provide only what Test::Screen needs.

## Test::Screen

Test::Screen will allow development environments that contain or
interface to interactive terminal applications to run non-interactive
tests on an emulated terminal.  This is not as thorough as interactive
tests on actual terminals, but it is better than no testing at all.

## External Requirements

GNU screen wil not be available everywhere that a Perl6 application may
be installed, so both packages gracefully "pass" tests unless it
is detected.  To actually run tests, screen should be installed
and from the perspective of the test environment, should be findable
as an executable named "screen" -- this does not need to be the
case for general use, as the package can work with custom installations,
it just needs to be that way for automated testing.
