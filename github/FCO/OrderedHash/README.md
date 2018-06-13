NAME
====

OrderedHash - A hash that you specify the possible keys and theirs order

SYNOPSIS
========

```perl6
use OrderedHash;

my %oh1 does OrderedHash = b => 2, c => 3, a => 1;

say %oh1.keys;                                      # (a b c)
say %oh1.values;                                    # (1 2 3)
say %oh1.kv;                                        # (a 1 b 2 c 3)
say %oh1.pairs;                                     # (a => 1 b => 2 c => 3)

my %oh2 does OrderedHash[Int] = b => 2, a => 1;

say %oh2.keys;                                      # (a b)
say %oh2.values;                                    # (1 2)
say %oh2.kv;                                        # (a 1 b 2)
say %oh2.pairs;                                     # (a => 1 b => 2)

%oh2<c> = 3;
say %oh2;                                           # {a => 1, b => 2, c => 3}

# %oh2<d> = "error";                                # dies

my %oh3 does OrderedHash[:keys<c b a>] = b => 2, c => 1, a => 3;

say %oh3.keys;                                      # (c b a)
say %oh3.values;                                    # (1 2 3)
say %oh3.kv;                                        # (c 1 b 2 a 3)
say %oh3.pairs;                                     # (c => 1 b => 2 a => 3)

my %oh4 does OrderedHash[Str, :keys<c b a>] = b => "b", c => "a", a => "c";

say %oh4.keys;                                      # (c b a)
say %oh4.values;                                    # (a b c)
say %oh4.kv;                                        # (c a b b a c)
say %oh4.pairs;                                     # (c => a b => b a => c)
```

DESCRIPTION
===========

OrderedHash is ...

AUTHOR
======

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

