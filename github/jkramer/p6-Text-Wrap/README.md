NAME
====

Text::Wrap - Wrap texts.

SYNOPSIS
========

    use Text::Wrap;

    say wrap-text($some-long-text);
    say wrap-text($some-long-text, :width(50));
    say wrap-text($some-long-text, :paragraph(rx/\n/));
    say wrap-text($text-with-very-long-word, :hard-wrap);

DESCRIPTION
===========

Text::Wrap provides a single function `wrap-text` that takes arbitrary text and wraps it to form paragraphs that fit the given width. There are three optional arguments that modify its behavior.

  * `:width(80)` sets the maximum width of a line. The default is 80 characters. If a single word is longer than this value, a line may become longer than this in order not to wrap the line in the middle of the word. This can be changed with `:hard-break`.

  * `:hard-break` makes `wrap-text` break lines in the middle of words that are longer than the maximum width. It's off by default, meaning that lines may become longer than the maximum width if the text contains words that are too long to fit a line.

  * `:paragraph(rx/\n ** 2..*/)` takes a `Regex` object which is used find paragraphs in the source text in order to retain them in the result. The default is `\n ** 2..*` (two or more consecutive linebreaks). To discard any paragraphs from the source text, you can set this to `Regex:U`.

  * `:prefix('')` takes a string that's inserted in front of every line of the wrapped text. The length of the prefix string counts into the total line width, meaning it's subtracted from the given `:width`.

AUTHOR
======

Jonas Kramer <jkramer@mark17.net>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Jonas Kramer.

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
