use v6;
use Test;
use License::Software;

my @result = License::Software::get-all;

plan 1;
ok @result, "get-all() found Licenses";
