NAME
====

Game::Sudoku::Solver - Attempt to solve Sudoku puzzles

DESCRIPTION
===========

Game::Sudoku::Solver provides a function that takes a Game::Sudoku puzzle and retuns the puzzle solved to the extent of it's abilities.

FUNCTIONS
=========

The following function is exported by default when is module is used.

solve-puzzle( Game::Sudoku -> Game::Sudoku )
--------------------------------------------

Takes a Game::Sudoku object and attempts to solve it by a series of simple tests looking for unique values. 

Once it's run out of simple solutions it will then try depth first tree solutions on the result. 

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
