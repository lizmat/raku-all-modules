use v6.c;
use Test;
use List::MoreUtils :all;

my @supported = <
  after after_incl all all_u any any_u apply arrayify before before_incl
  binsert bremove bsearch bsearchidx bsearch_index bsearch_insert
  bsearch_remove distinct duplicates each_array each_arrayref equal_range
  false firstidx first_index firstres first_result firstval first_value
  frequency indexes insert_after insert_after_string lastidx last_index
  lastres last_result lastval last_value listcmp lower_bound mesh minmax
  minmaxstr mode natatime nsort_by none none_u notall notall_u occurrences
  one one_u onlyidx only_index onlyres only_result onlyval only_value
  pairwise part reduce_0 reduce_1 reduce_u samples qsort singleton sort_by
  true uniq upper_bound zip zip6 zip_unflatten
>.map: '&' ~ *;

plan @supported * 2;

for @supported {
    ok defined(::($_)), "is $_ imported?";
    ok defined(List::MoreUtils::{$_}), "is $_ still externally accessible?";
}

# vim: ft=perl6 expandtab sw=4
