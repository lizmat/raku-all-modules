NAME
====

Pygments - Wrapper to python pygments library.

SYNOPSIS
========

Printing some code with a terminal formatter.

    use Pygments;

    my $code = q:to/ENDCODE/;
    grammar Parser {
        rule  TOP  { I <love> <lang> }
        token love { '♥' | love }
        token lang { < Perl Rust Go Python Ruby > }
    }

    say Parser.parse: 'I ♥ Perl';
    # OUTPUT: ｢I ♥ Perl｣ love => ｢♥｣ lang => ｢Perl｣

    say Parser.parse: 'I love Rust';
    # OUTPUT: ｢I love Rust｣ love => ｢love｣ lang => ｢Rust｣
    ENDCODE

    # Output to terminal with line numbers.
    Pygments.highlight(
        $code, "perl6", :formatter<terminal>,
        :linenos(True)
    ).say;

Also it can be used with `Pod::To::HTML`:

    use Pygments;

    # Set the pod code callback to use pygments before *use* it
    my %*POD2HTML-CALLBACKS;
    %*POD2HTML-CALLBACKS<code> = sub (:$node, :&default) {
        Pygments.highlight($node.contents.join('\n'), "perl6",
                           :style(Pygments.style('emacs')),
                           :full)
    };
    use Pod::To::HTML;
    use Pod::Load;

    pod2html(load('some.pod6'.IO)).say

DESCRIPTION
===========

Pygments is a wrapper for the [pygments](http://pygments.org) python library.

METHODS
=======

There's no need to instantiate the `Pygments` class. All the methods can be called directly.

highlight
---------

    method highlight(Str $code, $lexer, :$formatter = 'html', *%options)

Highlight the `$code` with the lexer passed by paramenter. If no lexer is provided, pygments will try to guess the lexer that will use.

style
-----

    method style(Str $name = 'default')

Get a single style with name `$name`

styles
------

    method styles

Return a list of all the available themes.

AUTHOR
======

Matias Linares <matiaslina@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 Matias Linares

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

