NAME
====

SeqSplitter - Creates `.pull-while`, `.pull-until`, `.pull`, `.skip-while`, `.skip-until` and `.skip` on `Seq` and `Any`.

SYNOPSIS
========

```perl6
use SeqSplitter;
say ^10
   .pull-while(* < 2)
   .skip-while(* < 5)
   .pull-until(7)
   .skip-until(8)
   .pull
   .skip(3)
;
```

Will print:
```
(0 1 5 6 8)
```

DESCRIPTION
===========

SeqSplitter is a "better solution" for `.toggle` it was being discussed here https://github.com/rakudo/rakudo/issues/2089

AUTHOR
======

Fernando Correa de Oliveira <fernandocorrea@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Fernando Correa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
