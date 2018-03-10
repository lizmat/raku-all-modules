Perl6 bindings for Munge, the MUNGE Uid 'N' Gid Emporium Authentication Service
===============================================================================

From the [main Munge wiki](https://github.com/dun/munge/wiki):

MUNGE (MUNGE Uid 'N' Gid Emporium) is an authentication service for
creating and validating credentials. It is designed to be highly
scalable for use in an HPC cluster environment. It allows a process to
authenticate the UID and GID of another local or remote process within
a group of hosts having common users and groups. These hosts form a
security realm that is defined by a shared cryptographic key. Clients
within this security realm can create and validate credentials without
the use of root privileges, reserved ports, or platform-specific
methods.

Installing
----------

Only tested with Linux, (Should easily port to Windows if anyone wants
to do that, patches welcome!)

Requires libmunge.so.2

Follow the [libmunge installation instruction](https://github.com/dun/munge/wiki/Installation-Guide).

For Ubuntu, it may be as simple as `sudo apt-get install libmunge-dev`

Usage
-----

See man pages for detailed usage, but this is the simple case:

Encode:

```perl6
use Munge;

my $encoded = Munge.new.encode('optional payload');
say $encoded;

```

Decode:
```perl6
use Munge;

my $encoded = ...

my $payload = Munge.new.decode($encoded);
```

Any errors are thrown as exceptions.

Examples
--------

Simple versions of `munge` and `unmunge` are in the `eg` directory
depicting more complicated usage, but don't use them, they are just
for illustration.

```
$ ./munge.p6 --help
Usage:
  ./munge.p6 [--cipher=<Str>] [--MAC=<Str>] [--zip=<Str>] [--ttl=<Int>] [--socket=<Str>] [--uid-restriction=<Int>] [--gid-restriction=<Int>]
```

Try this:
```
echo hi | ./munge.p6 | ./unmunge.p6
```

LICENSE
=======

Copyright © 2018 United States Government as represented by the
Administrator of the National Aeronautics and Space Administration. No
copyright is claimed in the United States under Title 17,
U.S.Code. All Other Rights Reserved.
