use v6.c;
use Test;
use List::UtilsBy;

my @supported = <
  bundle_by count_by extract_by extract_first_by max_by min_by minmax_by
  nmax_by nmin_by nminmax_by nsort_by partition_by rev_nsort_by rev_sort_by
  sort_by uniq_by unzip_by weighted_shuffle_by zip_by
>.map: '&' ~ *;

plan @supported * 2;

for @supported {
    ok !defined(::($_))                     # nothing here by that name
      || ::($_) !=== List::UtilsBy::{$_},   # here, but not from List::UtilsBy
      "is $_ NOT imported?";
    ok defined(List::UtilsBy::{$_}), "is $_ externally accessible?";
}

# vim: ft=perl6 expandtab sw=4
