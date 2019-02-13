use v6;
use Test;

plan 6;

use Date::Names;

my $dn;

# test the default class
$dn = Date::Names.new;
is $dn.dow(1), "Monday";
is $dn.mon(1), "January";
is $dn.dow(1, 3), "Mon";
is $dn.mon(1, 3), "Jan";

# special cases
$dn = Date::Names.new: :lang<en>, :day-hash<dow2>, :mon-hash<mon3>;
is $dn.dow(1), "Mo";
is $dn.mon(1), "Jan";
