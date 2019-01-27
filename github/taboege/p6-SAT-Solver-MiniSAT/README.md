NAME
====

SAT::Solver::MiniSAT - SAT solver MiniSAT

SYNOPSIS
========

``` perl6
use SAT::Solver::MiniSAT;

say minisat "t/aim/aim-100-1_6-no-1.cnf".IO, :now;
#= False
say minisat "t/aim/aim-100-1_6-yes1-1.cnf".IO, :now;
#= True
```

DESCRIPTION
===========

SAT::Solver::MiniSAT wraps the `minisat` executable (bunled with the module) used to decide whether a satisfying assignment for a Boolean formula given in the `DIMACS cnf` format exists. This is known as the `SAT` problem associated with the formula. MiniSAT does not produce a witness for satisfiability.

Given a DIMACS cnf problem, it starts `minisat`, feeds it the problem and returns a Promise which will be kept with the `SAT` answer found or broken on error.

AUTHOR
======

Tobias Boege <tboege ☂ ovgu ☇ de>

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Tobias Boege

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
