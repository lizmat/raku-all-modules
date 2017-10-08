# TAP::Harness

This is an asynchronous TAP framework writen in Perl 6

# Description

This module runs TAP test files and parses them asynchronously.

# How to use

bin/prove6 is the easiest way to use it. It's fairly basic but similar enough to p5's prove, e.g.

 prove6 -l t/basic.t

# TODO

These features are currently not implemented but are considered desirable:

 * Rule based parallel scheduling
 * SourceHandlers other than ::Perl6
 * Various prove arguments

