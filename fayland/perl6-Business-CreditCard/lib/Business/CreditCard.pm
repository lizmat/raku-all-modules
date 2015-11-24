unit module Business::CreditCard;

# https://en.wikipedia.org/wiki/Bank_card_number
sub _is_enRoute($num) {
    $num.starts-with('2014') || $num.starts-with('2149');
}

sub cardtype($num is copy) is export {
    $num = $num.subst(/<[\s\-]>+/, '', :g);

    my $len = $num.chars;
    my $f1 = $num.substr(0, 1).Int;
    my $f2 = $num.substr(0, 2).Int;
    my $f3 = $num.substr(0, 3).Int;
    my $f4 = $num.substr(0, 4).Int;
    my $f6 = $num.substr(0, 6).Int;

    return 'Visa' if $f1 == 4 and ($len == 13 or $len == 16);
    return 'MasterCard' if $num ~~ /^5<[1..5]>/ and $len == 16;
    return 'AmericanExpress' if $num ~~ /^3<[47]>/ and $len == 15;
    return 'enRoute' if _is_enRoute($num);

    return 'DinersClub' if ( $num ~~ /^30<[0..5]>/ || $f3 == 309 || $num ~~ /^3<[689]>/)
        and $len == 14;
    return 'DinersClub' if $num ~~ /^5[45]/ and $len == 16;

    # 6011, 622126-622925, 644-649, 65
    return 'Discover' if ( $f4 == 6011 || ($f6 >= 622126 and $f6 <= 622925) || ($f3 >= 644 and $f3 <= 649) || $num.starts-with('65') )
        and $len == 16;

    return 'InterPayment' if $f3 eq '639' and $len >= 16 and $len <= 19;
    return 'InstaPayment' if $f3 >= 637 and $f3 <= 639 and $len == 16;
    return 'JCB' if ($f4 >= 3528 and $f4 <= 3589) and $len == 16;
    return 'JCB' if ($f4 == 2131 or $f4 == 1800) and $len == 15;

    return 'Laser' if $f4 == 6304 or $f4 == 6706 or $f4 == 6771 or $f4 == 6709;

    return 'Dankort' if $f4 == 5019 and $len == 16;

    return 'Solo' if ($f4 == 6334 || $f4 == 6767) and ($len == 16 || $len == 18 || $len == 19);
    return 'Switch' if ($f4 == 4903 || $f4 == 4905 || $f4 == 4911 || $f4 == 4936 || $f6 == 564182 || $f6 == 633110 || $f4 == 6333 || $f4 == 6759) and ($len == 16 || $len == 18 || $len == 19);

    return 'ChinaUnionPay' if $f2 == 62 and $len >= 16 and $len <= 19;

    return 'UATP' if $f1 == 1 and $len == 15;

    # 50, 56-69
    return 'Maestro' if ( $f2 == 50 || ($f2 >= 56 and $f2 <= 69) )
        and $len >= 12 and $len <= 19;

    return '';
}

sub validate($num is copy) is export {
    if _is_enRoute($num) {
        return True;
    }

    $num = $num.subst(/\D+/, '', :g);

    my $sum = 0; my $even = False;
    for (0 .. $num.chars - 1).reverse -> $i {
        my $char = substr($num, $i, 1).Int;
        $char *= 2 if $even;
        $char -= 9 if $char > 9;
        $sum  += $char;
        $even = ! $even;
    }

    return ($sum % 10) == 0;
}