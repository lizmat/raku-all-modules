NAME
====

LCS::BV - Bit Vector (BV) implementation of the Longest Common Subsequence (LCS) Algorithm

html
====

<a href="https://travis-ci.org/wollmers/P6-LCS-BV"><img src="https://travis-ci.org/wollmers/P6-LCS-BV.png" alt="P6-LCS-BV"></a>

SYNOPSIS
========

      use LCS::BV;

      $lcs = LCS::BV::LCS($a,$b);

ABSTRACT
========

LCS::BV implements the Longest Common Subsequence (LCS) Algorithm and is more than double as fast (Jan 2016) than Algorithm::Diff::LCSidx().

DESCRIPTION
===========

This module is a port from the Perl5 module with the same name.

The algorithm used is based on

    H. Hyyroe. A Note on Bit-Parallel Alignment Computation. In
    M. Simanek and J. Holub, editors, Stringology, pages 79-87. Department
    of Computer Science and Engineering, Faculty of Electrical
    Engineering, Czech Technical University, 2004.

METHODS
-------

  * LCS($a,$b)

Finds a Longest Common Subsequence, taking two arrayrefs as method arguments. It returns an array reference of corresponding indices, which are represented by 2-element array refs.

SEE ALSO
========

Algorithm::Diff

AUTHOR
======

Helmut Wollmersdorfer lthelmut.wollmersdorfer@gmail.comgt
