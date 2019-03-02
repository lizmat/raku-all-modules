#!/usr/bin/env perl6

use Grid;

my @array = < a b c d e f g h i j k l m n o p q r s t u v w x >;

@array does Grid[:4columns];

@array.grid;

@array.transpose;

say '';

@array.grid;
