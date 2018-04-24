[![Build Status](https://travis-ci.org/lizmat/List-AllUtils.svg?branch=master)](https://travis-ci.org/lizmat/List-AllUtils)

NAME
====

List::AllUtils - Port of Perl 5's List::AllUtils 0.14

SYNOPSIS
========

    use List::AllUtils qw( first any );
     
    # _Everything_ from List::Util, List::MoreUtils, and List::UtilsBy
    use List::AllUtils qw( :all );
     
    my @numbers = ( 1, 2, 3, 5, 7 );
    # or don't import anything
    return List::AllUtils::first { $_ > 5 } @numbers;

DESCRIPTION
===========

Are you sick of trying to remember whether a particular helper is defined in [List::Util](List::Util), [List::MoreUtils](List::MoreUtils) or [List::UtilsBy](List::UtilsBy)? Now you don't have to remember. This module will export all of the functions that either of those three modules defines.

Which One Wins?
---------------

`List::AllUtils` always favors the version provided by [List::Util](List::Util), [List::MoreUtils](List::MoreUtils) or [List::UtilsBy](List::UtilsBy) in that order.

Where is the documentation?
---------------------------

Rather than copying the documentation and running the risk of getting out of date, please check the original documentation using the following mapping:

### List::Util

    all any first max maxstr min minstr none notall pairfirst pairgrep pairkeys
    pairmap pairs pairvalues product reduce shuffle sum sum0 uniq uniqnum uniqstr
    unpairs

### List::MoreUtils

    after after_incl all_u any_u apply arrayify before before_incl binsert
    bremove bsearch bsearch_index bsearch_insert bsearch_remove bsearchidx
    distinct duplicates each_array each_arrayref equal_range false first_index
    first_result first_value firstidx firstres firstval frequency indexes
    insert_after insert_after_string last_index last_result last_value lastidx
    lastres lastval listcmp lower_bound mesh minmax minmaxstr mode natatime
    none_u notall_u nsort_by occurrences one one_u only_index only_result
    only_value onlyidx onlyres onlyval pairwise part qsort reduce_0 reduce_1
    reduce_u samples singleton sort_by true upper_bound zip zip6 zip_unflatten

### List::UtilsBy

    bundle_by count_by extract_by extract_first_by max_by min_by minmax_by
    nmax_by nmin_by nminmax_by partition_by rev_nsort_by rev_sort_by uniq_by
    unzip_by weighted_shuffle_by zip_by

AUTHOR
======

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/List-AllUtils . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5 version developed by Dave Rolsky.

