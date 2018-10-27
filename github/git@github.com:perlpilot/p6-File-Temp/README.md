[![Build status](https://ci.appveyor.com/api/projects/status/github/perlpilot/p6-File-Temps?svg=true)](https://ci.appveyor.com/project/perlpilot/p6-File-Temps/branch/master)

NAME
====

File::Temp

SYNOPSIS
========

    # Generate a temp file in a temp dir
    my ($filename,$filehandle) = tempfile;

    # specify a template for the filename
    #  * are replaced with random characters
    my ($filename,$filehandle) = tempfile("******");

    # Automatically unlink files at DESTROY (this is the default)
    my ($filename,$filehandle) = tempfile("******", :unlink);

    # Specify the directory where the tempfile will be created
    my ($filename,$filehandle) = tempfile(:tempdir("/path/to/my/dir"));

    # don't unlink this one
    my ($filename,$filehandle) = tempfile(:tempdir('.'), :!unlink);

    # specify a prefix and suffix for the filename
    my ($filename,$filehandle) = tempfile(:prefix('foo'), :suffix(".txt"));

DESCRIPTION
===========

This module exports two routines:

  * `tempfile` creates a temporary file and returns a filehandle to that file 
    opened for writing and the filename of that temporary file

  * `tempdir` creates a temporary directory and returns the directory name.

AUTHOR
======

Jonathan Scott Duff <duff@pobox.com>
