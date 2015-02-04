# TAP::Harness

This is an asynchronous TAP framework writen in Perl 6

# Description

This module runs TAP test files and parses them asynchronously.

# WARNING

This module uses Proc::Async to run your tests, however as for writing (September 2014) there are issues in correctly capturing from multiple processes at the same time in Rakudo, running more than one test file using this framework is not recommended until these issues are resolved.

# How to use

bin/prove6 is the easiest way to use it. It's fairly basic but similar enough to p5's prove, e.g.

 prove6 -l t/basic.t

# TODO

These features are currently not implemented but are considered desirable:

 * Parallel console outputting
 * Rule based parallel scheduling
 * SourceHandlers other than ::Perl6
 * Various prove arguments
 * Serialize/deserialize YAMLish

# TAP outputting

This distribution also offers TAP outputting modules. Test::More is the end-user visible part of this.
