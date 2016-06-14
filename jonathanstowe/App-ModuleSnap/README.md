# App::ModuleSnap

Create a "snapshot" of the installed Perl 6 modules so they can be reinstalled later.

## Synopsis

```

	p6-module-snap [--directory=<dir>}


```

Then at some point later in the directory it created:

```
	panda install .

```

## Description

This provides a facility to take a "snapshot" of the Perl 6 modules you have installed
on your system in the form of a skeleton distribution with the modules as dependencies
which can be used to reinstall the modules or even install them fresh on a new machine.

The key use cases for this kind of thing would be either that you need to remove and
reinstall your perl 6 installation (rather than just upgrading in place that will
leave the modules as they were,) or you want deploy the same modules on another machine
to run some application (or duplicate a development environment.)

This is similar in intent to the ```autobundle``` command of Perl 5's ```cpan``` command.

It should work with any module installer that uses the standard Perl 6 installation
mechanisms (such as ```panda``` or ```zef```) and should in theory work with any new
ones that may come along as it simply writes a minimal META file into an otherwise
bare directory.  The META file contains the installed modules as it's dependencies
just a like a normal module might.

## Installation

Assuming you have a working rakudo Perl 6 installation you can install with ```panda```:

	panda install App::ModuleSnap

which will install the script and the small supporting module.

Whilst I haven't tested this it should work equally as well with ```zef```.

## Support

This is very simple, but if you have any suggestions/patches etc please send them
via github at https://github.com/jonathanstowe/App-ModuleSnap/issues .

## Licence and Copyright

This is free software. Please see the [LICENCE](LICENCE) file in the distribution.

© Jonathan Stowe 2016

