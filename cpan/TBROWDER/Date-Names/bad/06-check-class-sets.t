use v6;
use Test;

plan 80;

use Date::Names;


my $dn;

# test the default class
$dn = Date::Names.new;

is $dn.dow(1), "Monday";
is $dn.mon(1), "January";

# special cases
$dn = Date::Names.new: :lang<en>, :dset<dow2>, :mset<mon3>;
is $dn.dow(1), "Mo";
is $dn.mon(1), "Jan";

# more
for 1..12 -> $m {
    for @mnames -> $n {
        my $d = Date::Names.new: :mset($n);
        my $v = $d.mon($m);
        if $v {
            like $d.mon($m), /\S/;
        }
        else {
            nok $d.mon($m);
        }
    }
}
for 1..7 -> $w {
    for @dnames -> $n {
        my $d = Date::Names.new: :dset($n);
        my $v = $d.dow($w);
        if $v {
            like $d.dow($w), /\S/;
        }
        else {
            nok $d.dow($w);
        }
    }
}
