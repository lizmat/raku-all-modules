use v6;
use Test;

plan 10;

use Date::Names;

# Check correct values
my $mon = 1;
is %Date::Names::mon{$mon}, "January";
is %Date::Names::mon<en>{$mon}, "January";

is %Date::Names::mon3{$mon}, "Jan";
is %Date::Names::mon3<en>{$mon}, "Jan";

my $day = 1;
is %Date::Names::dow{$day}, "Monday";
is %Date::Names::dow<en>{$day}, "Monday";

is %Date::Names::dow3{$day}, "Mon";
is %Date::Names::dow3<en>{$day}, "Mon";

is %Date::Names::dow2{$day}, "Mo";
is %Date::Names::dow2<en>{$day}, "Mo";
