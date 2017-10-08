# perl6-Proc-Screen
Perl6 programmatic interface for manipulating GNU screen sesssions

## Status

This is in "release early" status.  Basic use of Proc::Screen may
work and Test::Screen may also work, but has very few available tests.
The version of GNU screen must be 4.02 (a.k.a. 4.2) or greater since
there is no way I know of to get the session ID back from a detached launch
on prior versions.

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
