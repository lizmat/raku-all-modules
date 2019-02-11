LWP::Simple for Perl 6
=================

[![Build Status](https://travis-ci.org/perl6/perl6-lwp-simple.svg?branch=master)](https://travis-ci.org/perl6/perl6-lwp-simple)

This is a quick & dirty implementation of a LWP::Simple clone for Rakudo Perl 6; it does both `GET` and `POST` requests.

Dependencies
============

LWP::Simple depends on the modules MIME::Base64 and URI,
which you can find at http://modules.perl6.org/. The tests depends
on [JSON::Tiny](https://github.com/moritz/json).

Write:

    zef install --deps-only .
    
You'll have to
install [IO::Socket::SSL](https://github.com/sergot/io-socket-ssl) via

    zef install IO::Socket::SSL
    
if you want to work with `https` too.

Synopsis
========

```perl6
use LWP::Simple;

my $content = get("https://perl6.org");

my $response = post("https://somewhere.topo.st", { so => True }
```


Current status
==============

You can
use [HTTP::UserAgent](https://github.com/sergot/http-useragent)
instead, with more options. However, this module will do just fine in
most cases. 

Use
===

Use the installed commands:

     lwp-download.p6  http://eu.httpbin.org

Or

     lwp-download.p6  https://docs.perl6.org 
     
If `ÌO::Socket::SSL` has been installed.

    lwp-get.p6  https://perl6.org
    
will instead print to standard output.
