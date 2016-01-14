
use v6;

unit module Cardinal:ver<0.2.1>:auth<github:thundergnat>;

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

my @d = < 0     first    second    third      fourth     fifth     sixth     seventh     eighth     ninth
          tenth eleventh twelfth   thirteenth fourteenth fifteenth sixteenth seventeenth eighteenth nineteenth >;
my @t = < ''    ''       twentieth thirtieth  fortieth   fiftieth  sixtieth  seventieth  eightieth  ninetieth >;

sub cardinal ($rat is copy, :$separator = ' ', :$common, :$improper ) is export {
    if $rat.substr(0,1) eq '-' {
        return "negative {cardinal($rat.substr(1).Rat, :separator($separator), :common($common), :improper($improper)) }"
    }
    $rat .= Rat;
    return cardinal-int($rat.narrow) if $rat.narrow ~~ Int;
    my ($num, $denom) = $rat.nude;
    if $common { # handle common denominator setup
        $num = ($rat * $common).round;
        $denom = $common;
    }
    my $s; # String to accumulate cardinal

    unless $improper {
        # handle improper fractions
        my $whole = $num div $denom;
        $num %= $denom;
        # add whole number
        $s ~= cardinal-int($whole) if $whole;
        # return if there are no fractional portions
        return $s // 'zero' unless $num;
        # add 'and' separator between whole and fractional
        $s ~= ' and ' if $whole;
    }

    # numerator is just a regular cardinal, add a separator if desired
    $s ~= cardinal-int($num) ~ $separator;
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
            $s ~= cardinal-int($mil).substr(4);
        } else {
            $s ~= cardinal-int($mil) if $mil;
        }
        if +$cen { # most of the special casing takes place in the last 3 digits
            $s ~= ' ' if $mil;
            if $cen %% 100 {
                if $cen == 100 and not $mil {
                    # Drop the one for even one hundreth
                    $s ~= 'hundreth'
                } else {
                    $s ~= cardinal-int($cen) ~ 'th'
                }
            } elsif $cen > 100 {    # irregulars galore
                my $hun = $cen.substr(0,1) * 100;
                $cen -= $hun;
                $s ~= cardinal-int($hun) ~ ' ';
                if $cen %% 10 {
                    $s ~=  @t[$cen / 10]
                } else {
                    if $cen > 19 {
                        my $ten = $cen.substr(0,1) * 10;
                        $s ~= cardinal-int($ten) ~ '-' if +$ten;
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
                    $s ~= cardinal-int((+$cen).substr(0,1) * 10)
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

sub cardinal-int (Int $int) {
    if $int.substr(0,1) eq '-' { return "negative {cardinal-int($int.substr(1))}" }
    if $int == 0 { return @I[0] }
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

sub cardinal-year ($year where 0 < $year < 10000) is export {
    if $year %% 1000 {
        return cardinal($year.substr(0,1)) ~ ' thousand';
    } elsif $year %% 100  {
        my ($, $cen) = $year.flip.comb(/\d ** 1..2/);
        return cardinal($cen.flip) ~ ' hundred';
    }
    my ($l, $h) = $year.flip.comb(/\d ** 1..2/).».flip;
    if $l < 10 {
        return cardinal($h) ~ ' ought-' ~ cardinal($l);
    }
    return join ' ', cardinal($h), cardinal($l);
}
