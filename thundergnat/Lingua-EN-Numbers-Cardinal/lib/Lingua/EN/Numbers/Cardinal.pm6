
use v6;

unit module Cardinal:ver<2.0.0>:auth<github:thundergnat>;

# Arrays probably should be constants but constant arrays and pre-comp
# don't get along very well right now.
my @I = <zero one    two    three    four     five    six     seven     eight    nine
         ten  eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen>;
my @X = <0    X      twenty thirty   forty    fifty   sixty   seventy   eighty   ninety>;
my @C = @I »~» ' hundred';
my @M = (<0 thousand>,
    ((<m b tr quadr quint sext sept oct non>,
    (map { ('', <un duo tre quattuor quin sex septen octo novem>).flat X~ $_ },
    <dec vigint trigint quadragint quinquagint sexagint septuagint octogint nonagint>),
    'cent').flat X~ 'illion')).flat;

my @d = < zeroth first    second    third      fourth     fifth     sixth     seventh     eighth     ninth
          tenth  eleventh twelfth   thirteenth fourteenth fifteenth sixteenth seventeenth eighteenth nineteenth >;
my @t = < ''     ''       twentieth thirtieth  fortieth   fiftieth  sixtieth  seventieth  eightieth  ninetieth >;


multi sub cardinal ($rat is copy, :sep(:$separator) = ' ', :den(:$denominator), :im(:$improper) ) is export {
    if $rat.substr(0,1) eq '-' {
        return "negative {cardinal($rat.substr(1).Rat, :separator($separator), :denominator($denominator), :improper($improper)) }"
    }
    $rat .= Numeric.Rat;
    return cardinal($rat.narrow) if $rat.narrow ~~ Int;
    my ($num, $denom) = $rat.nude;
    if $denominator { # handle common denominator setup
        $num = ($rat * $denominator).round;
        $denom = $denominator;
    }
    my $s; # String to accumulate cardinal

    unless $improper {
        # handle improper fractions
        my $whole = $num div $denom;
        $num %= $denom;
        # add whole number
        $s ~= cardinal($whole) if $whole;
        # return if there are no fractional portions
        return $s // 'zero' unless $num;
        # add 'and' separator between whole and fractional
        $s ~= ' and ' if $whole;
    }

    # numerator is just a regular cardinal, add a separator if desired
    $s ~= cardinal($num) ~ $separator;
    # now determine the denominator
    if $denom == 2 { # special case irregular halfs
        if $num == 1 {
            $s ~= 'half';
        } else {
            $s ~= 'halves'
        }
        return $s;
    } elsif $denom == 4 { # special case irregular fourths
        $s ~= 'quarter';
        $s ~= 's' if $num != 1;
        return $s;
    } else { # special case even 'one' magnitude denominators
        my $cen = $denom.chars > 3 ?? $denom.substr(*-3) !! $denom;
        my $mil = $denom - $cen;
        if ($mil.chars == 3 || ($mil.chars - 1) %% 3) && not +$cen
         && +$mil.substr(0,1) == 1 && +$mil.substr(1) == 0 {
            # Drop the one for one thousandth, one millionth, etc
            $s ~= cardinal($mil).substr(4);
        } else {
            $s ~= cardinal($mil) if $mil;
        }
        if +$cen { # most of the special casing takes place in the last 3 digits
            $s ~= ' ' if $mil;
            if $cen %% 100 {
                if $cen == 100 and not $mil {
                    # Drop the one for even one hundredth
                    $s ~= 'hundredth'
                } else {
                    $s ~= cardinal($cen) ~ 'th'
                }
            } elsif $cen > 100 {    # irregulars galore
                my $hun = $cen.substr(0,1) * 100;
                $cen -= $hun;
                $s ~= cardinal($hun) ~ ' ';
                if $cen %% 10 {
                    $s ~=  @t[$cen / 10]
                } else {
                    if $cen > 19 {
                        my $ten = $cen.substr(0,1) * 10;
                        $s ~= cardinal($ten) ~ '-' if +$ten;
                        $s ~=  @d[$cen.substr(*-1)];
                    } else {
                        $s ~=  @d[$cen];
                    }
                }
            } elsif $cen && $cen < 20 {
                $s ~=  @d[$cen];
            } else {
                if $cen %% 10 {
                    $s ~=  @t[$cen / 10]
                } else {
                    $s ~= cardinal((+$cen).substr(0,1) * 10)
                    ~ '-' ~ @d[$cen.substr(*-1)];
                }
            }
        } else { # add suffix for denominator with 000 for last three digits
            $s ~= 'th';
        }
        # correct for pluralization
        $s ~= 's' if $num != 1;
        $s;
    }
}

multi sub cardinal (Int $int) is export {
    if $int.substr(0,1) eq '-' { return "negative {cardinal($int.substr(1))}" }
    if $int == 0 { return @I[0] } # Bools dispatch as Ints.
    if $int == 1 { return @I[1] } # Handle them directly
    my $m = 0;
    return join ', ', reverse gather for $int.flip.comb(/\d ** 1..3/) {
        my ( $i, $x, $c ) = .comb».Int;
        if $i or $x or $c {
            take join ' ', gather {
                if $c { take @C[$c] }
                if $x and $x == 1 { take @I[$i+10] }
                else {
                    if $x and $i {
                        take join '-', @X[$x], @I[$i];
                    } else {
                        if $x { take @X[$x] }
                        if $i { take @I[$i] }
                    }
                }
                take @M[$m] // fail "WOW! ZILLIONS!\n" if $m;
            }
        }
        $m++;
    }
}

multi sub cardinal (Num $num) is export {
    if $num < 0 { return "negative {cardinal(-$num)}" }
    die if $num ~~ Inf or $num ~~ NaN;
    my ($mantissa, $exponent) = $num.fmt('%e').split('e')».Numeric;
    my ($whole, $fraction) = $mantissa.split('.')».Numeric;
    my $f = ($fraction.defined) ?? join( ' ', ' point', @I[$fraction.comb]) !! '';
    "{@I[$whole.comb]}$f times ten to the { $exponent.&ordinal }";
}

sub cardinal-year ($year where 0 < $year < 10000, :$oh = 'oh-' ) is export {
    if $year %% 1000 {
        return cardinal($year.substr(0,1)) ~ ' thousand';
    } elsif $year %% 100  {
        my ($, $cen) = $year.flip.comb(/\d ** 1..2/);
        return cardinal($cen.flip) ~ ' hundred';
    }
    my ($l, $h) = $year.flip.comb(/\d ** 1..2/).».flip;
    if $h and $l < 10 {
        return cardinal($h) ~ ' ' ~ $oh ~ cardinal($l);
    } elsif $l < 10 {
        return cardinal($l);
    }
    return join ' ', cardinal($h), cardinal($l);
}

sub ordinal ($int is copy) is export {
    $int .= Int;
    if $int < 0 { return "negative {ordinal($int.abs)}" }
    my $ten = $int.chars > 2 ?? +$int.substr(*-2) !! +$int;
    my $mil = $int - $ten;
    my $s = '';
    if $mil > 0 {
        $s = cardinal($mil);
    }
    if +$mil and !+$ten { return $s ~ 'th' }
    if +$mil and  +$ten { $s ~= ' ' }
    if $ten < 20 {
        $s ~= @d[$ten]
    } elsif +$ten and $ten %% 10 {
        $s ~= @t[$ten div 10]
    } else {
        $s ~= cardinal($ten div 10 * 10) ~ '-' ~ @d[$ten % 10]
    }
    $s;
}

sub ordinal-digit ($int is copy) is export {
    $int .= Int;
    my $ten = $int.abs.chars > 2 ?? +$int.substr(*-2) !! +$int.abs;
    my $s = $int;

    if 10 < $ten < 14  {
        $s ~= "th";
    } else {
        given $int.substr(*-1) {
            when 1  { $s ~= "st" }
            when 2  { $s ~= "nd" }
            when 3  { $s ~= "rd" }
            default { $s ~= "th" }
        }
    }
    $s;
}
