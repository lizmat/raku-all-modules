use Test;

# Language 'nl' class
plan 85;

my $lang = 'nl';

use Date::Names;

my $dn;

# these data are auto-generated:
# non-empty data set arrays
my @dow  = <maandag dinsdag woensdag donderdag vrijdag zaterdag zondag>;
my @dow2 = <ma di wo do vr za zo>;
my @dow3 = <maa din woe don vri zat zon>;
my @mon  = <januari februari maart april mei juni juli augustus september oktober november december>;
my @mon3 = <jan feb maa apr mei jun jul aug sep okt nov dec>;
my @sets = <dow dow2 dow3 mon mon3>;

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
