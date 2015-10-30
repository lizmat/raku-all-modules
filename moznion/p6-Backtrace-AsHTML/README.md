[![Build Status](https://travis-ci.org/moznion/p6-Backtrace-AsHTML.svg?branch=master)](https://travis-ci.org/moznion/p6-Backtrace-AsHTML)

NAME
====

Backtrace::AsHTML - Displays back trace in HTML

SYNOPSIS
========

    use Backtrace::AsHTML;

    my $trace = Backtrace.new;
    my $html  = $trace.as-html;

DESCRIPTION
===========

Backtrace::AsHTML adds `as-html` method to [Backtrace](Backtrace) which displays the back trace in beautiful HTML, with code snippet context.

<img src="https://i.gyazo.com/6ac7f82ef6fb0a05d7de9a11dbdcaa0b.png">

This library is inspired by [Devel::StackTrace::AsHTML of perl5](https://metacpan.org/release/Devel-StackTrace-AsHTML) and much of code is taken from that.

METHODS
=======

  * `as-html`

`as-html` shows the fully back trace in HTML.

This method will be added into [Backtrace](Backtrace) class automatically when used this.

TODO
====

  * show lexical variables for each frames (How?)

  * show arguments for each frames? (How??)

AUTHOR
======

moznion <moznion@gmail.com>

COPYRIGHT AND LICENSE
=====================

    Copyright 2015 moznion

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And license of the original perl5's Devel::StackTrace::AsHTML is

    This library is free software; you can redistribute it and/or modify
    it under the same terms as Perl itself.
