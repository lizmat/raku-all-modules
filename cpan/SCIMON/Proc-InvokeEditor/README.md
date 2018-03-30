[![Build Status](https://travis-ci.org/Scimon/p6-Proc-InvokeEditor.svg?branch=master)](https://travis-ci.org/Scimon/p6-Proc-InvokeEditor)

NAME
====

Proc::InvokeEditor - Edit strings in an external editor. 

SYNOPSIS
========

    use Proc::InvokeEditor;

    my $editor = Proc::InvokeEditor( :editors( [ "/usr/bin/emacs" ] ) );
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

editors_env( @editors )
-----------------------

Object method only, given an array (or positional arguments) of Str keys will prepend to the editors array the value for that key in ENV (if one is defined).

Returns the current list of editors.

Fails if called as a class method. 

editors_prepend( @editors )
---------------------------

Object method only, given an array (or positional arguments) of Str values will prepend them to the editor list.

Returns the current list of editors.

Fails if called as a class method.

first_usable()
--------------

Class or object method. Returns an array of executable path string and then optional parameters for the editor the system will use when edit() is called.

edit( $string )
---------------

Class or object method, takes a string or list of strings. Fires up the external editor specifed by first_usable() and waits for it to complete then returns the updated result.

TODO
====

  * Windows support.

  * Addtional Perl6-isms including Async editting allowing background processes.

NOTE
====

The original Perl5 module includes methods to turn off auto cleanup of temp files and to reuse the same file. This functionality is not planned for this version of the module, if required please raise a ticket.

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

Original Perl5 Module Authored by Micheal Stevens

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
