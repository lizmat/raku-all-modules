use v6;
use Test;
use Lingua::EN::Numbers::Cardinal;

plan *;

# single digits
is ordinal(0), "zeroth", "0 is zeroth";
is ordinal(1), "first", "1 is first";
is ordinal(2), "second", "2 is second";
is ordinal(3), "third", "3 is third";
is ordinal(4), "fourth", "4 is fourth";
is ordinal(5), "fifth", "5 is fifth";
is ordinal(6), "sixth", "6 is sixth";
is ordinal(7), "seventh", "7 is seventh";
is ordinal(8), "eighth", "8 is eighth";
is ordinal(9), "ninth", "9 is ninth";

# those pesky numbers from 10..19 are special
is ordinal(10), "tenth", "10 is tenth";
is ordinal(11), "eleventh", "11 is eleventh";
is ordinal(12), "twelfth", "12 is twelfth";
is ordinal(13), "thirteenth", "13 is thirteenth";
is ordinal(14), "fourteenth", "14 is fourteenth";
is ordinal(15), "fifteenth", "15 is fifteenth";
is ordinal(16), "sixteenth", "16 is sixteenth";
is ordinal(17), "seventeenth", "17 is seventeenth";
is ordinal(18), "eighteenth", "18 is eighteenth";
is ordinal(19), "nineteenth", "19 is nineteenth";

# checking on 20, 30 ... 90
is ordinal(20), "twentieth", "20 is twentieth";
is ordinal(30), "thirtieth", "30 is thirtieth";
is ordinal(40), "fortieth", "40 is fortieth";
is ordinal(50), "fiftieth", "50 is fiftieth";
is ordinal(60), "sixtieth", "60 is sixtieth";
is ordinal(70), "seventieth", "70 is seventieth";
is ordinal(80), "eightieth", "80 is eightieth";
is ordinal(90), "ninetieth", "90 is ninetieth";

# hundreds
is ordinal(100), "one hundredth", "100 is one hundredth";
is ordinal(200), "two hundredth", "200 is two hundredth";
is ordinal(350), "three hundred fiftieth", "350 is three hundred fiftieth";
is ordinal(402), "four hundred second", "402 is four hundred second";
is ordinal(544), "five hundred forty-fourth", "544 is five hundred forty-fourth";
is ordinal(612), "six hundred twelfth", "612 is six hundred twelfth";

# thousands
is ordinal(1000), "one thousandth", "1000 is one thousandth";
is ordinal(2000), "two thousandth", "2000 is two thousandth";
is ordinal(3006), "three thousand sixth", "3006 is three thousand sixth";
is ordinal(4032), "four thousand thirty-second", "4032 is four thousand thirty-second";
is ordinal(5931), "five thousand, nine hundred thirty-first", "5931 is five thousand, nine hundred thirty-first";
is ordinal(6400), "six thousand, four hundredth", "6400 is six thousand, four hundredth";
is ordinal(7070), "seven thousand seventieth", "7070 is seven thousand seventieth";
is ordinal(8316), "eight thousand, three hundred sixteenth", "8316 is eight thousand, three hundred sixteenth";

# ten thousands
is ordinal(10000), "ten thousandth", "10000 is ten thousandth";
is ordinal(16000), "sixteen thousandth", "16000 is sixteen thousandth";
is ordinal(20639), "twenty thousand, six hundred thirty-ninth", "20639 is twenty thousand, six hundred thirty-ninth";

# hundred thousands
is ordinal(100000), "one hundred thousandth", "100000 is one hundred thousandth";
is ordinal(160000), "one hundred sixty thousandth", "160000 is one hundred sixty thousandth";
is ordinal(200042), "two hundred thousand forty-second", "200042 is two hundred thousand forty-second";
is ordinal(329923), "three hundred twenty-nine thousand, nine hundred twenty-third", "329923 is three hundred twenty-nine thousand, nine hundred twenty-third";

# millions
is ordinal(1000000), "one millionth", "1000000 is one millionth";
is ordinal(2000000), "two millionth", "2000000 is two millionth";
is ordinal(3542000), "three million, five hundred forty-two thousandth", "3542000 is three million, five hundred forty-two thousandth";

# billions (of the US variety, that is)
is ordinal(1000000000), "one billionth", "1000000000 is one billionth";
is ordinal(2000030000), "two billion, thirty thousandth", "2000030000 is two billion thirty thousandth";
is ordinal(3040005000), "three billion, forty million, five thousandth", "3040005000 is three billion, forty million, five thousandth";

# trillions
is ordinal(1000000000000), "one trillionth", "1000000000000 is one trillionth";
is ordinal(1000002300000), "one trillion, two million, three hundred thousandth", "1000002300000 is one trillion, two million, three hundred thousandth";

# larger number
is ordinal(999999999999999), "nine hundred ninety-nine trillion, nine hundred ninety-nine billion, nine hundred ninety-nine million, nine hundred ninety-nine thousand, nine hundred ninety-ninth", "999999999999999 is nine hundred ninety-nine trillion, nine hundred ninety-nine billion, nine hundred ninety-nine million, nine hundred ninety-nine thousand, nine hundred ninety-ninth";

# what about a number that's big?
my $googol = ('1' ~ ('0' xx 100).join).Int; # a googol!
is ordinal(+$googol), "ten duotrigintillionth", "googol: $googol is ten duotrigintillionth";

# how about non integers, coerce to sensible values
is ordinal(''), "zeroth", "0 is zeroth";
is ordinal('1'), "first", "1 is first";
is ordinal('2'), "second", "2 is second";
is ordinal(3.2), "third", "3 is third";
is ordinal(4.7), "fourth", "4 is fourth";
is ordinal(5e0), "fifth", "5 is fifth";
is ordinal(30/5), "sixth", "6 is sixth";


done-testing;
