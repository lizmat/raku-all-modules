use v6;
use Test;

plan 10;

use Date::Names :ALL;

# Check correct values
my $mon = 1;
is %mon{$mon}, "January";
is %mon<en>{$mon}, "January";

is %mon3{$mon}, "Jan";
is %mon3<en>{$mon}, "Jan";

my $day = 1;
is %dow{$day}, "Monday";
is %dow<en>{$day}, "Monday";

is %dow3{$day}, "Mon";
is %dow3<en>{$day}, "Mon";

is %dow2{$day}, "Mo";
is %dow2<en>{$day}, "Mo";

