[![Build Status](https://travis-ci.org/hipek8/p6-Statistics-LinearRegression.svg?branch=master)](https://travis-ci.org/hipek8/p6-Statistics-LinearRegression)

NAME
====

Statistics::LinearRegression - simple linear regression

SYNOPSIS
========

Gather some data

    my @arguments = 1,2,3;
    my @values = 3,2,1;

Build model and predict value for some x using object

    use Statistics::LinearRegression;
    my $x = 15;
    my $y = my LR.new(@arguments, @values).at($x);

If you prefer bare functions, use :ALL

    use Statistics::LinearRegression :ALL;
    my ($slope, $intercept) = get-parameters(@arguments, @values);
    my $x = 15;
    my $y = value-at($x, $slope, $intercept);

DESCRIPTION
===========

LinearRegression finds slope and intercept parameters of linear function by minimizing mean square error.

Value at y is calculated using `y = slope × x + intercept`

TODO
====

  * R^2 and p-value calculation 

  * support for other objective functions

CHANGES
=======

  * 1.1.0 LR class exported by default, bare subroutines need :ALL

AUTHOR
======

Paweł Szulc <pawel_szulc@onet.pl>

COPYRIGHT AND LICENSE
=====================

Copyright 2016 Paweł Szulc

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
