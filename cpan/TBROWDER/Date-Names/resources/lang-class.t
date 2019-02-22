<!-- begin part 1 ========================== --> use v6;
use Test;

<!-- end part 1 ============================ -->



<!-- part 1 data =========================== -->
# Language '{$L}' class
my $lang = {$L};
plan $N;

<!-- begin part 2 ========================== -->
use Date::Names;

my $dn;

# these data are auto-generated:
# non-empty data set arrays
<!-- end part 2 ============================ -->

<!-- part 2 data =========================== -->
my @dow = <>; # <== data set array values
# ...
my @mon = <>;
# ...
my @sets;

<!-- begin part 3 ========================== -->

for @sets -> $n {
    my $ne = $n ~~ /^d/ ?? 7 !! 12;
    my @v = @::($n); # <== interpolated from $n

    my $is-dow;
    if $ne == 7 {
        $dn = Date::Names.new: :$lang, :dset($n);
        $is-dow = 1;
    }
    else {
        $dn = Date::Names.new: :$lang, :mset($n);
        $is-dow = 0;
    }

    # test the class construction
    isa-ok $dn, Date::Names;
    # test class methods (6)
    can-ok $dn, 'nsets';
    can-ok $dn, 'sets';
    can-ok $dn, 'show';
    can-ok $dn, 'show-all';
    can-ok $dn, 'dow';
    can-ok $dn, 'mon';
    # test the data array
    is @v.elems, $ne;

    # test the main methods for return values
    for 1..$ne -> $d {
        my $val = @v[$d-1];
        if $is-dow {
            is $dn.dow($d), $val;
        }
        else {
            is $dn.mon($d), $val;
        }
    }
}
<!--  end part 3 -->
