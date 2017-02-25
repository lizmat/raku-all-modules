
use lib <lib>;
use Test;
plan 2;

use M '♥';
is-deeply (^3, [^4], '5')♥.Numeric, (3, 4, 5), '.Numeric works';
is-deeply (^5, [^6], '9')♥.Numeric, (5, 6, 9), '.Numeric works the second time';
