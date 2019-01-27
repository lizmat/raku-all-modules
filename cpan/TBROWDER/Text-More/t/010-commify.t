use v6;
use Test;

use Text::More :ALL;

plan 8;

my $n1 = 1000; # an int
my $n2 = '1000';
my $n3 = '1000.0000';
my $n7 = 1035.06; # a real number
my $n8 = 100000000;
my $n4 = '1000000000.0000'; # 9 zeroes before decimal point
my $n5 = '1003000000.0000'; # 9 zeroes before decimal point
my $n6 = '1000000000.1000'; # 9 zeroes before decimal point

is commify($n1), '1,000';
is commify($n2), '1,000';
is commify($n3), '1,000.0000';
is commify($n7), '1,035.06';
is commify($n8), '100,000,000';
is commify($n4), '1,000,000,000.0000';
is commify($n5), '1,003,000,000.0000';
is commify($n6), '1,000,000,000.1000';
