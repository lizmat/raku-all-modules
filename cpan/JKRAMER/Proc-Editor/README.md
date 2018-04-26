[![Build Status](https://travis-ci.org/jkramer/p6-proc-editor.svg?branch=master)](https://travis-ci.org/jkramer/p6-proc-editor)

NAME
====

Proc::Editor - Start a text editor

SYNOPSIS
========

    use Proc::Editor;

    my $text = edit('original text');
    say "Edited text: {$text.trim}";

DESCRIPTION
===========

Proc::Editor runs a text editor and returns the edited text.

ROUTINES
========

`edit(...)`
-----------

This is merely a shortcut for convenience, all arguments are passed on to `Proc::Editor.new.edit(...)`.

METHODS
=======

`new(:editors(...))`
--------------------

Create a new instance of `Proc::Editor`. `:editors` may be used to override the default list of editors to try. By default, the environment variables $VISUAL and $EDITOR are checked, then it tries /usr/bin/vi, /bin/vi and /bin/ed (in that order).

`edit(Str $text?, IO::Path :$file, Bool :$keep)`
------------------------------------------------

Writes `$text` to a temporary file runs an editor with that file as argument. On success, the contents of the file are returned. If `$file` is defined, it is used instead of creating a temporary file. The file used (temporary or not) are deleted afterwards unless `:keep` is provided.

`edit-file(IO::Path $path)`
---------------------------

Starts an editor with the given `$path` as argument. Returns the editors exit-code on success (which should always be 0) or dies on error.

AUTHOR
======

Jonas Kramer <jkramer@mark17.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Jonas Kramer

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

