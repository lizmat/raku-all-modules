use v6;
use Test;
plan 6;
use Text::Levenshtein::Damerau;


# These tests should be moved to t/ once perl6 is faster

# dld
{
    is( dld('four' x 100, 'fuor' x 100),      100,  'dld lengths of 400');
    is( dld('four' x 100, 'fuor' x 100, 99),  Nil,  'dld lengths of 400 exceeding max value');
    is( dld('four' x 100, 'fuor' x 100, 101), 100,  'dld lengths of 400 under max value');
}

# ld
{
    is( ld('four' x 100, 'fuor' x 100),       200,  'ld lengths of 400');
    is( ld('four' x 100, 'fuor' x 100, 199),  Nil,  'ld lengths of 400 exceeding max value');
    is( ld('four' x 100, 'fuor' x 100, 201),  200,  'ld lengths of 400 under max value');
}
