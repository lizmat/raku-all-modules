use v6;
use Test;
use Business::CreditCard;

my @et = (
    '',         # null
    'MasterCard',
    'Visa',
    'AmericanExpress',
    'DinersClub',
    'Discover',
    'enRoute',
    'JCB',
);

# format -- card number, expected value from @et
my @tv = (
# mastercard
    ['5100-2222 3333 4414', 1],
    ['5200 2222 3333 4454', 1],
    ['5300 2222 3333 4404', 1],
    ['5400 2222 3333 4494', 1],
    ['5400 2222 3333 4444', 0], # bad crc
    ['5400 2222 3333 4494 0', 0],   # too long
    ['5500 2222 3333 4451', 1],
# visa
    ['4000 2222 3333 4434', 2],
    ['4000 2222 3333 6', 2],
    ['4000 2222 3333 4444', 0], # bad crc
    ['4000 2222 3333 4', 0],    # bad crc
    ['4000 2222 3333 4434 0', 0],   # too long
    ['4000 2222 3333 60', 0],   # too long
# amex
    ['3400 2222 3333 447', 3],
    ['3700 2222 3333 440', 3],
    ['3400 2222 3333 444', 0],  # bad crc
    ['3400 2222 3333 4470', 0], # too long
# diners/carteblanche
    ['3000 2222 3333 46', 4],
    ['3010 2222 3333 44', 4],
    ['3020 2222 3333 42', 4],
    ['3030 2222 3333 40', 4],
    ['3040 2222 3333 48', 4],
    ['3050 2222 3333 45', 4],
    ['3600 2222 3333 40', 4],
    ['3800 2222 3333 48', 4],
    ['3800 2222 3333 44', 0],   # bad crc
    ['3800 2222 3333 490', 0],  # too long
# discover
    ['6011 2222 3333 4444', 5],
    ['6011 2222 3333 4445', 0], # bad crc
    ['6011 2222 3333 44440', 0],    # too long
# enRoute
    ['2014 2222',   6],     # no crc
    ['2014 2223',   6],
    ['2014 2222 3333 4444 5555', 6], # no lenth
# jcb, FIXME, we have problems with JCB
    # ['3100 2222 3333 4443', 7],
    ['3100 2222 3333 4443 0', 0],   # too long
    ['2131 2222 3333 464', 7],
    ['1800 2222 3333 424', 7],
    ['2131 2222 3333 4640', 0], # too long
    ['1800 2222 3333 4240', 0], # too long
);
for @tv -> $tv {
    my ($num, $rst) = $tv.list;
    if ($rst) {
        ok validate($num), "$num is ok";
        my $cardtype = cardtype($num);
        is $cardtype, @et[$rst], "$num -> $cardtype";
    } else {
        ok ! validate($num), "$num is not ok";
    }
}

done-testing;