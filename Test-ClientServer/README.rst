==================
Test::ClientServer
==================

This is a Perl 6 module to make tests involving network daemons and whatnot a
bit easier to write and understand. For working examples, check the test files.

It works by spinning off two threads for code blocks containing server/client
code, and synchronising their startup using a semaphore.
