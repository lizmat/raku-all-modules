[![Build Status](https://travis-ci.org/zengargoyle/p6-Search-Dict.svg?branch=master)](https://travis-ci.org/zengargoyle/p6-Search-Dict)

NAME
====

Search::Dict - a fast binary search of dictionary like files

SYNOPSIS
========

    use Search::Dict;

    my &lookup = search-dict('/usr/share/dict/words');

    given lookup('existing-word') -> $w {
      +$w;  # seek offset in dict
      ?$w;  # True
      ~$w;  # 'existing-word'
    }
    given lookup('non-existing-word') -> $w {
      +$w;  # seek offset after where non-existing-word would be
      ?$w;  # False
      ~$w;  # word after where non-existing-word would be
      # or
      $w.match.defined # False  - after last word in dict
    }

DESCRIPTION
===========

Search::Dict is a fast binary search of dictionary like files (e.g. /usr/share/dict/words). A dictionary file is one where:

one entry per line

lines are sorted

AUTHOR
======

zengargoyle <zengargoyle@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2015 zengargoyle

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
