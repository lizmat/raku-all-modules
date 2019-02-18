unit module T::F;

use T::F::en;

class T::F {
    has $.dow ;
    has %.d;
    submethod TWEAK() {
        $!dow = $::("en::dow");
    }

    method dow($n is copy where {$n > 0 && $n < 8}) {
        --$n; #CRITICAL 
        $.dow[$n]
    }
}

