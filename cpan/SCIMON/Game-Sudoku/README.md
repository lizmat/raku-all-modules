[![Build Status](https://travis-ci.org/Scimon/p6-Game-Sudoku.svg?branch=master)](https://travis-ci.org/Scimon/p6-Game-Sudoku)

NAME
====

Game::Sudoku - Store, validate and solve sudoku puzzles

SYNOPSIS
========

    use Game::Sudoku;

    # Create an empty game
    my $game = Game::Sudoku.new();
    # Set some cells
    $game.cell(0,0,1).cell(0,1,2);
    # Test the results
    $game.valid();
    $game.full();
    $game.complete();

    # Get possible values for a cell
    $game.possible(0,2);

DESCRIPTION
===========

Game::Sudoku is a simple library to store, test and attempt to solve sudoku puzzles.

Currently the libray can be used as a basis for doing puzzles and can solve a number of them. I hope to add additional functionality to it in the future.

The Game::Sudoku::Solver module includes documenation for using the solver.

METHODS
=======

new( Str :code -> Game::Sudoku )
--------------------------------

The default constructor will accept and 81 character long string comprising of combinations of 0-9. This code can be got from an existing Game::Sudoku object by calling it's .Str method.

valid( -> Bool )
----------------

Returns True if the sudoku game is potentially valid, IE noe row, colum or square has 2 of any number. A valid puzzle may not be complete.

full( -> Bool )
---------------

Returns True if the sudoku game has all it's cells set to a non zero value. Note that the game may not be valid.

complete( -> Bool )
-------------------

Returns True is the sudoku game is both valid and full.

possible( Int, Int, Bool :$set -> List )
----------------------------------------

Returns the sorted Sequence of numbers that can be put in the current cell. Note this performs a simple check of the row, column and square the cell is in it does not perform more complex logical checks.

Returns an empty List if the cell already has a value set or if there are no possible values.

If the optional :set parameter is passed then returns a Set of the values instead.

cell( Int, Int -> Int )
-----------------------

cell( Int, Int, Int -> Game::Sudoku )
-------------------------------------

Getter / Setter for individual cells. The setter returns the updated game allowing for method chaining. Note that attempting to set a value defined in the constructor will not work, returning the unchanged game object.

row( Int -> List(List) )
------------------------

Returns the list of (x,y) co-ordinates in the given row. 

col( Int -> List(List) )
------------------------

Returns the list of (x,y) co-ordinates in the given column. 

square( Int -> List(List) )
---------------------------

square( Int, Int -> List(List) )
--------------------------------

Returns the list of (x,y) co-ordinates in the given square of the grid. A square can either be references by a cell within it or by it's index.

    0|1|2
    -----
    3|4|5
    -----
    6|7|8

reset( Str :$code )
-------------------

Resets the puzzle to the state given in the $code argument. If the previous states initial values are all contained in the new puzzle then they will not be updated. Otherwise the puzzle will be treated as a fresh one with the given state.

AUTHOR
======

Simon Proctor <simon.proctor@gmail.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2017 Simon Proctor

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
