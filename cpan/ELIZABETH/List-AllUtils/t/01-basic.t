use v6.c;
use Test;
use List::AllUtils;

my @supported = <
  after after_incl all all_u any any_u apply arrayify before before_incl
  binsert bremove bsearch bsearch_index bsearch_insert bsearch_remove
  bsearchidx bundle_by count_by distinct duplicates each_array each_arrayref
  equal_range extract_by extract_first_by false first first_index first_result
  first_value firstidx firstres firstval frequency indexes insert_after
  insert_after_string last_index last_result last_value lastidx lastres
  lastval listcmp lower_bound max max_by maxstr mesh min min_by minmax
  minmax_by minmaxstr minstr mode natatime nmax_by nmin_by nminmax_by none
  none_u notall notall_u nsort_by occurrences one one_u only_index only_result
  only_value onlyidx onlyres onlyval pairfirst pairgrep pairkeys pairmap
  pairs pairvalues pairwise part partition_by product qsort reduce reduce_0
  reduce_1 reduce_u rev_nsort_by rev_sort_by samples shuffle singleton sort_by
  sum sum0 true uniq uniq_by uniqnum uniqstr unpairs unzip_by upper_bound
  weighted_shuffle_by zip zip6 zip_by zip_unflatten
>.map: '&' ~ *;

plan @supported * 2;

for @supported {
    ok !defined(::($_))                    # nothing here by that name
      || ::($_) !=== List::AllUtils::{$_}, # here, but not from List::AllUtils
      "is $_ NOT imported?";
    ok defined(List::AllUtils::{$_}), "is $_ externally accessible?";
}

# vim: ft=perl6 expandtab sw=4
