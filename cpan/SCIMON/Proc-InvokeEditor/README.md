[![Build Status](https://travis-ci.org/Scimon/p6-Proc-InvokeEditor.svg?branch=master)](https://travis-ci.org/Scimon/p6-Proc-InvokeEditor)

NAME
====

Proc::InvokeEditor - Edit strings in an external editor. 

SYNOPSIS
========

    use Proc::InvokeEditor;

    my $editor = Proc::InvokerEditor( :editors( [ "/usr/bin/emacs" ] ) );
    my $text = $editor->edit( "Edit text below\n" );

DESCRIPTION
===========

Proc::InvokeEditor is a port of the Perl5 module of the same name. The API is intended to be as close as possible to the original. Later versions of the module will add additional functionality

METHODS
=======

new( :editors )
---------------

Create a new Proc::InvokeEditor object, takes an optional list of paths to editors to attempt to use. Note: currently all paths given must be complete paths, the system doesn't attempt an checking of the path environment for files.

Editor strings can include command line arguments to pass and should expect to take a filename as there final argument.

editors()
---------

Getter / Setter for the array of editors accepts a postional arguments or an postitional and sets the list of editors to that. If called with no values gives the current list in the order they will be checked.

Can be called as a getter as a class method but will error if you try and set the editors as a class method.

first_usable()
--------------

Class or object method. Returns an array of executable path string and then optional parameters for the editor the system will use when edit() is called.

edit( $string )
---------------

Class or object method, takes a string or list of strings. Fires up the external editor specifed by first_usable() and waits for it to complete then returns the updated result.

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
