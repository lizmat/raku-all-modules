unit package Number::Denominate:ver<1.001001>;
use Lingua::Conjunction;

my %Units =
    time => (
        week => 7,
            day => 24,
                hour => 60,
                    minute => 60,
                        'second'
    ),
    weight => (
        tonne => 1000,
            kilogram => 1000,
                'gram'
    ),
    weight-imperial => (
        ton => 160,
            stone => 14,
                pound => 16,
                    'ounce'
    ),
    length => (
        'light year' => 9_460_730_472.5808,
            kilometer => 1000,
                'meter'
    ),
    length-mm => (
        'light year' => 9_460_730_472.5808,
            kilometer => 1000,
                meter => 100,
                    centimeter => 10,
                        'millimeter'
    ),
    length-imperial => (
        mile => 1760,
            yard => 3,
                <foot feet> => 12,
                    <inch inches>
    ),
    volume => (
        Liter => 1000,
            'milliliter'
    ),
    volume-imperial => (
        gallon => 4,
            quart => 2,
                pint => 20,
                    'fluid ounce'
    ),
    info => (
        yottabyte => 1000, zettabyte => 1000, exabyte => 1000, petabyte => 1000,
        terabyte  => 1000, gigabyte => 1000, megabyte => 1000, kilobyte => 1000,
        'byte'
    ),
    'info-1024' => (
        yobibyte => 1024, zebibyte => 1024, exbibyte => 1024, pebibyte => 1024,
        tebibyte => 1024, gibibyte => 1024, mebibyte => 1024, kibibyte => 1024,
        'byte'
    ),
;

subset ValidUnitSet of Str where any <time weight weight-imperial length
    length-mm length-imperial volume volume-imperial info info-1024>;

sub denominate (
    $num is copy,
    ValidUnitSet :$set = 'time',
    Bool :$array       = False,
    Bool :$hash        = False,
    Bool :$string      = ($array or $hash) ?? False !! True,
    :@units is copy    = %Units{ $set },
    Int  :$precision where $_ >= 1 = @units.elems,
) is export {
    # Normalize units
    for @units {
        $_ ~~ Pair or $_ = $_ => 1;
        $_ ~~ Pair and .key ~~ Str
            and $_ = (.key, .key ~ 's') => .value;
        $_ = %(
            singular     => .key[0],
            plural       => .key[1],
            denomination => .value,
            value        => 0,
        );
    }

    # Short-curcuit on this special case:
    if $num == 0 {
        $string and return "0 @units[*-1]<plural>";
        $hash   and return %();
        $array  and return @units;
    }

    my $mult *= $_<denomination> for @units;
    for @units {
        my $n = $num.Int div $mult.Int;
        $num -= $mult*$n;
        $mult /= $_<denomination>;
        $_<value> = $n;
    }

    if $precision < @units.elems {
        my $set = 0;
        for 0 .. @units.end -> $idx is copy {
            my $u = @units[$idx];
            next unless $u<value>;
            next unless ++$set > $precision;
            # we have too many units if we got up to here

            # Reset any remaining units to zero
            @units[$_]<value> = 0  for $idx+1 .. @units.end;

            # just drop out if rounding doesn't increase previous unit
            if ( $u<value> / @units[$idx-1]<denomination> < .5 ) {
                $u<value> = 0;
                last;
            }

            # Set value of our current unit to zero, since we're rounding it.
            # Switch to the previous unit. If it's not set, just bail out,
            # since increasing it will mean we'll have too many units again
            loop {
                $u<value> = 0;
                $u = @units[--$idx];

                if $idx == 0 or (
                    not $u<value> and not @units[0..$idx-1].grep({$_<value>})
                ) {
                    # Either we're at the top unit, or there are no set units
                    # higher up. Just increase this one and bail.
                    $u<value>++;
                    last;
                }
                last unless $u<value>;
                last unless ++$u<value> == @units[$idx-1]<denomination>;
                # If we got here, we overflown the unit, so we need to bump
                # the next previous one
            }
            last;
        }
    }

    return @units if $array;
    @units .= grep({ $_<value> });
    $hash and return %( @units.map({ $_<singular> => $_<value> }) );
    $string and return conjunction @units.map({
        $_<value> == 1 ?? "$_<value> $_<singular>" !! "$_<value> $_<plural>"
    });
}
