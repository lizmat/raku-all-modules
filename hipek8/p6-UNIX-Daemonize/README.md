[![Build Status](https://travis-ci.org/hipek8/p6-UNIX-Daemonize.svg?branch=master)](https://travis-ci.org/hipek8/p6-UNIX-Daemonize)

NAME
====

(WIP) UNIX::Daemonize - run external commands or Perl6 code as daemons

SYNOPSIS
========

    use UNIX::Daemonize;
    daemonize(<xcowsay mooo>, :repeat, :pid-file</var/lock/mycow>);

Then, if you're not a fan of cows repeatedly jumping at you 

    terminate-process-group-from-file("/var/lock/mycow");

This daemon is actually 2 processes: perl6 script you ran above, and external command 'xcowsay', 'mooo'  both same process group. That's why we're terminating whole PG

You can also daemonize Perl6 code to be run after daemonize call (note no positional arguments):

    use UNIX::Daemonize;
    daemonize(:pid-file</var/lock/mycow>);
    Promise.in(15).then({exit 0;});
    loop { qq:x/xcowsay moo/; }

`daemonize` binary provided too – you can daemonize directly from shell:

    $ daemonize --pid-file='lock' --repeat xcowsay moo
    $ kill -15 -`cat lock` && rm lock

Negative PID kills whole PGID

DESCRIPTION
===========

UNIX::Daemonize is configurable daemonizing tool written in Perl 6.

Requirements:

  * POSIX compliant OS (fork, umask, setsid …)

  * Perl6

  * xcowsay to run demo above :)

(WIP)

BUGS / CONTRIBUTING
===================

Repo can be found [https://github.com/hipek8/p6-UNIX-Daemonize](https://github.com/hipek8/p6-UNIX-Daemonize). Feel free to contribute.

Let me know if you find any bug (not that I'll be surprised…). If you can correct it, PR is our friend.

KNOWN ISSUES:

  * stdout/stderr redirects ignored when running shell set to True, use shell redirects

  * tests fail for osx, investigate and add to travis

AUTHOR
======

Paweł Szulc <pawel_szulc@onet.pl>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Paweł Szulc

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
