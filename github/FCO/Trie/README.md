[![Build Status](https://travis-ci.org/FCO/Trie.svg?branch=master)](https://travis-ci.org/FCO/Trie)

NAME
====

Trie - A pure perl6 implementation of the trie data structure.

SYNOPSIS
========

```perl6
use Trie;
my Trie $t .= new;

$t.insert: $_ for <ability able about above accept according account>;
$t.insert: "agent", {complex => "data"};

say $t.get-all:    "ab";     # (ability able about above)
say $t.get-all:    "abov";   # (above)
say $t.get-single: "abov";   # "above"
#   $t.get-single: "ab";     # dies

say $t.get-single: "agent";  # {complex => "data"}

$t<all>   = 1;
$t<allow> = 2;
say $t<all>;                 # (1 2)

say $t[0];                   # ability
say $t[0 .. 3];              # (ability able about above)

say $t.find-substring: "cc"; # (accept according account)
say $t.find-fuzzy:     "ao"; # set(2 about above according account)
```

DESCRIPTION
===========

Trie is a pure perl6 implementation of the trie data structure.

AUTHOR
======

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

