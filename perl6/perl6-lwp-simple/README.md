Perl6 LWP::Simple
=================

[![Build Status](https://travis-ci.org/perl6/perl6-lwp-simple.svg?branch=master)](https://travis-ci.org/perl6/perl6-lwp-simple)

http://github.com/perl6/perl6-lwp-simple/

This is a quick & dirty  implementation
of a LWP::Simple clone for Rakudo Perl 6.

Since Perl 6 is a bit new, this LWP::Simple does both
get and post requests.

Dependencies
============

LWP::Simple depends on the modules MIME::Base64 and URI,
which you can find at http://modules.perl6.org/


Current status
==============

As of 2011-04-22, runs with all recent rakudo builds.
It correctly follows redirects, but no infinite redirects
detection yet.
