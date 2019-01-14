# Linux::Cpuinfo

Obtain Linux CPU information.

[![Build Status](https://travis-ci.org/jonathanstowe/p6-Linux-Cpuinfo.svg?branch=master)](https://travis-ci.org/jonathanstowe/p6-Linux-Cpuinfo)

## Synopsis

```perl6
  use Linux::Cpuinfo;

  my $cpuinfo = Linux::Cpuinfo.new();

  my $cnt  = $cpuinfo.num-cpus();   # > 1 for an SMP system

  for $cpuinfo.cpus -> $cpu {
     say $cpu.bogomips;
  }
```

## Description

On Linux systems various information about the CPU ( or CPUs ) in the
computer can be gleaned from ```/proc/cpuinfo```. This module provides an
object oriented interface to that information for relatively simple use
in Perl programs.

## Installation

Assuming you have a working perl6 installation you should be able to
install this with *zef* :

    # From the source directory
   
    zef install .

    # Remote installation

    zef install Linux::Cpuinfo

## Support

Suggestions/patches are welcomed via github at https://github.com/jonathanstowe/p6-Linux-Cpuinfo/issues

I'd be particularly interested in the /proc/cpuinfo from a variety of
architectures to test against, the ones that I already have can be seen
in t/proc

I'm not able to test on a wide variety of platforms so any help there
would be appreciated.

## Licence

Please see the [LICENCE](LICENCE) file in the distribution.

© Jonathan Stowe 2015, 2016, 2017, 2019
