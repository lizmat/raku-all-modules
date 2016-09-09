# Perl6-Acme::Sudoku

[![Build Status](https://travis-ci.org/pierre-vigier/Perl6-Acme-Sudoku.svg?branch=master)](https://travis-ci.org/pierre-vigier/Perl6-Acme-Sudoku)

NAME
====

Acme::Sudoku

SYNOPSIS
========

Simple sudoku solver, keeping the Sudoku namespace clean, as it will use really naive algorithm

DESCRIPTION
===========

This module provides a naive sudoku solver

    use Acme::Sudoku;

    my $game = Acme::Sudoku.new( q:to/END/ );
    . . . . . 8 . . .
    7 . . . . . 9 . 5
    . 1 4 . 3 5 8 . .
    . 2 . . 1 6 . 3 .
    . 5 . . . 9 6 . 1
    8 . . . . . . . 4
    3 . 9 2 . . 1 . .
    . . 6 1 . 7 . . 2
    1 . . 5 . . . 7 .
    END

    $game.solve;
    say $game;

The only algorithm implemented now is for each case, looking for missing value in row/column/square. If we can reduce the missing set to 1 element, case is filled. That algorithm does not enusre the finding of a solution, and works only for extremly easy sudoku grid.
