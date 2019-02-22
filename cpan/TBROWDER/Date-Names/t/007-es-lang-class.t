use Test;

# Language 'es' class
plan 140;

my $lang = 'es';

use Date::Names;

my $dn;

# these data are auto-generated:
# non-empty data set arrays
my @dow  = <lunes martes miércoles jueves viernes sábado domingo>;
my @dow2 = <lu ma mi ju vi sá do>;
my @dow3 = <lun mar mié jue vie sáb dom>;
my @dowa = <lun. mart. miér. juev. vier. sáb. dom.>;
my @mon  = <enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre>;
my @mon2 = <en fb mr ab my jn jl ag sp oc nv dc>;
my @mon3 = <ene feb mar abr may jun jul ago sep oct nov dic>;
my @mona = <en. febr. mzo. abr. my. jun. jul. ag. sept. oct. nov. dic.>;
my @sets = <dow dow2 dow3 dowa mon mon2 mon3 mona>;

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
