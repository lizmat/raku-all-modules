[![Build Status](https://travis-ci.org/moznion/p6-HTML-Escape.svg?branch=master)](https://travis-ci.org/moznion/p6-HTML-Escape)

NAME
====

HTML::Escape - Utility of HTML escaping

SYNOPSIS
========

    use HTML::Escape;

    escape-html("<^o^>"); # => '&lt;^o^&gt;'

DESCRIPTION
===========

HTML::Escape provides a function which escapes HTML's special characters. It performs a similar function to PHP's htmlspecialchars.

This module is perl6 port of [HTML::Escape of perl5](https://metacpan.org/pod/HTML::Escape).

Functions
=========

`escape-html(Str $raw-str) returns Str`
---------------------------------------

Escapes HTML's special characters in given string.

TODO
====

  * Support unescaping function?

SEE ALSO
========

[HTML::Escape of perl5](https://metacpan.org/pod/HTML::Escape)

COPYRIGHT AND LICENSE
=====================

    Copyright 2017- moznion <moznion@gmail.com>

    This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

And original perl5's HTML::Escape is

    This software is copyright (c) 2012 by Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF@ GMAIL COME<gt>.

    This is free software; you can redistribute it and/or modify it under
    the same terms as the Perl 5 programming language system itself.
