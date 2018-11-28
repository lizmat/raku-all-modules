Perl6 LWP::Simple
=================

[![Build Status](https://travis-ci.org/perl6/perl6-lwp-simple.svg?branch=master)](https://travis-ci.org/perl6/perl6-lwp-simple)

This is a quick & dirty  implementation of a LWP::Simple clone for Rakudo Perl 6; it does both get and post requests.

Dependencies
============

LWP::Simple depends on the modules MIME::Base64 and URI,
which you can find at http://modules.perl6.org/. The tests depends
on [JSON::Tiny](https://github.com/moritz/json).


Current status
==============

You can
use [HTTP::UserAgent](https://github.com/sergot/http-useragent)
instead, with more options. However, this module will do just fine in
most cases. 

