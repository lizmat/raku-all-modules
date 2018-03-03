use v6.c;
use Net::LibIDN2;
use Test;

plan 1;

ok IDN2_VERSION_MAJOR >= 2, 'LibIDN2 v2.0.0 or greater must be installed!';

done-testing;
