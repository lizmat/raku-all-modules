use v6.c;

module List::AllUtils:ver<0.0.3>:auth<cpan:ELIZABETH> {
    use List::Util;
    use List::MoreUtils;
    use List::UtilsBy;

    BEGIN {
        for
          List::Util::EXPORT::SUPPORTED::,
          List::MoreUtils::EXPORT::all::,
          List::UtilsBy::EXPORT::all::
        -> $stash {
            for $stash.grep(*.key.starts-with("&")) {
                trait_mod:<is>(
                  (List::AllUtils::{.key} = .value), # available externally
                  :SYMBOL(.key),                     # use this name, not own
                  :export(:all)                      # make it export with :all
                ) unless List::AllUtils::{.key}:exists;  # if we don't have one
            }
        }
    }
}

sub EXPORT(*@args, *%_) {
    if @args {
        my $imports := Map.new( |(EXPORT::all::{ @args.map: '&' ~ * }:p) );
        if $imports != @args {
            die "List::AllUtils doesn't know how to export: "
              ~ @args.grep( { !$imports{$_} } ).join(', ')
        }
        $imports
    }
    else {
        Map.new
    }
}

=begin pod

=head1 NAME

List::AllUtils - Port of Perl 5's List::AllUtils 0.14

=head1 SYNOPSIS
 
    use List::AllUtils qw( first any );
 
    # _Everything_ from List::Util, List::MoreUtils, and List::UtilsBy
    use List::AllUtils qw( :all );
 
    my @numbers = ( 1, 2, 3, 5, 7 );
    # or don't import anything
    return List::AllUtils::first { $_ > 5 } @numbers;

=head1 DESCRIPTION
 
Are you sick of trying to remember whether a particular helper is
defined in L<List::Util>,  L<List::MoreUtils> or L<List::UtilsBy>? Now you
don't have to remember. This module will export all of the functions
that either of those three modules defines.
 
=head2 Which One Wins?
 
C<List::AllUtils> always favors the version provided by L<List::Util>,
L<List::MoreUtils> or L<List::UtilsBy> in that order.

=head2 Where is the documentation?

Rather than copying the documentation and running the risk of getting out of
date, please check the original documentation using the following mapping:

=head3 List::Util

  all any first max maxstr min minstr none notall pairfirst pairgrep pairkeys
  pairmap pairs pairvalues product reduce shuffle sum sum0 uniq uniqnum uniqstr
  unpairs

=head3 List::MoreUtils

  after after_incl all_u any_u apply arrayify before before_incl binsert
  bremove bsearch bsearch_index bsearch_insert bsearch_remove bsearchidx
  distinct duplicates each_array each_arrayref equal_range false first_index
  first_result first_value firstidx firstres firstval frequency indexes
  insert_after insert_after_string last_index last_result last_value lastidx
  lastres lastval listcmp lower_bound mesh minmax minmaxstr mode natatime
  none_u notall_u nsort_by occurrences one one_u only_index only_result
  only_value onlyidx onlyres onlyval pairwise part qsort reduce_0 reduce_1
  reduce_u samples singleton sort_by true upper_bound zip zip6 zip_unflatten

=head3 List::UtilsBy

  bundle_by count_by extract_by extract_first_by max_by min_by minmax_by
  nmax_by nmin_by nminmax_by partition_by rev_nsort_by rev_sort_by uniq_by
  unzip_by weighted_shuffle_by zip_by

=head1 AUTHOR

Elizabeth Mattijsen <liz@wenzperl.nl>

Source can be located at: https://github.com/lizmat/List-AllUtils . Comments
and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Elizabeth Mattijsen

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

Re-imagined from the Perl 5 version as part of the CPAN Butterfly Plan. Perl 5
version developed by Dave Rolsky.

=end pod

# vim: ft=perl6 expandtab sw=4
