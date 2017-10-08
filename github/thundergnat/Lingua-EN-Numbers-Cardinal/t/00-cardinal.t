use v6;
use Test;
use Lingua::EN::Numbers::Cardinal;

plan *;

is((join ', ', (1..10)».&cardinal), 'one, two, three, four, five, six, seven, eight, nine, ten', 'Int list');

is(cardinal(0), 'zero', '0 Int');
is(cardinal(-1), 'negative one', '-1 Int');
is(cardinal(-1008), 'negative one thousand, eight', '-1008 Int');
is(cardinal(10019), 'ten thousand, nineteen', '10019 Int');
is(cardinal(-1234567812), 'negative one billion, two hundred thirty-four million, five hundred sixty-seven thousand, eight hundred twelve', '-1234567812 Int');
is(cardinal(42000), 'forty-two thousand', '42000 Int');
is(cardinal(198723483017417), 'one hundred ninety-eight trillion, seven hundred twenty-three billion, four hundred eighty-three million, seventeen thousand, four hundred seventeen', '198723483017417 Int');


is((join ', ', map {cardinal($_/8)}, 0..8),
  'zero, one eighth, one quarter, three eighths, one half, five eighths, three quarters, seven eighths, one', 'Rat list');

is((join ', ', map {cardinal($_/8, denominator => 8) }, 0..8),
  'zero, one eighth, two eighths, three eighths, four eighths, five eighths, six eighths, seven eighths, one', 'Rat list common');

 {
      my @t = ( 'one', 'one tenth', 'one hundredth', 'one thousandth',
            'one ten thousandth', 'one one hundred thousandth',
            'one millionth', 'one ten millionth', 'one one hundred millionth',
            'one billionth', 'one ten billionth', 'one one hundred billionth',
            'one trillionth'
      );
      for 0..12 -> $d {
         is( cardinal( 1 / 10 ** $d ), @t[$d], 'order of magnitude ones' )
     }
 }

is(cardinal(3/16), 'three sixteenths', '3/16 Rat');
is(cardinal(1/50), 'one fiftieth', '1/50 Rat');
is(cardinal(1/101), 'one one hundred first', '1/101 Rat');
is(cardinal(7/150), 'seven one hundred fiftieths', '7/150 Rat');

is(cardinal(15/1000), 'three two hundredths', '15/1000 Rat');
is(cardinal(15/1000, denominator => 1000), 'fifteen thousandths', '15/1000 Rat common');
is(cardinal(15/1000, :denominator(1000)), 'fifteen thousandths', '15/1000 Rat common');
is(cardinal(20/1000, :den(1000)), 'twenty thousandths', '20/1000 Rat common');
is(cardinal(27/16, :denominator(32), :improper), 'fifty-four thirty-seconds', '27/16 Rat common improper');

is(cardinal(7/2), 'three and one half', '7/2 Rat');
is(cardinal(7/2, :improper), 'seven halves', '7/2 Rat improper');
is(cardinal(-7/2, :improper), 'negative seven halves', '-7/2 Rat improper');
is(cardinal(15/4, :im), 'fifteen quarters', '15/4 Rat improper');
is(cardinal(15/4), 'three and three quarters', '15/4 Rat');

is(cardinal(97873/10000000),
  'ninety-seven thousand, eight hundred seventy-three ten millionths', '97873/10000000 Rat separator');
is(cardinal(97873/10000000, separator => '/'),
  'ninety-seven thousand, eight hundred seventy-three/ten millionths', '97873/10000000 Rat separator');
is(cardinal(17/57, sep => '/'), 'seventeen/fifty-sevenths', '17/57 Rat separator');

is(cardinal(1/100.FatRat), 'one hundredth', '1/100 FatRat');
is(cardinal(-1/1000.FatRat), 'negative one thousandth', '-1/1000 FatRat');
is(cardinal(1/10000.FatRat), 'one ten thousandth', '1/10000 FatRat');
is(cardinal(-1/1000000.FatRat), 'negative one millionth', '-1/1000000 FatRat');

is(cardinal('12'), 'twelve', '12 String');
is(cardinal('-123'), 'negative one hundred twenty-three', '-123 String');
is(cardinal('12/34'), 'six seventeenths', '12/34 String');
is(cardinal('-12/34'), 'negative six seventeenths', '-12/34 String');
is(cardinal('-35/12'), 'negative two and eleven twelfths', '-35/12 String');
is(cardinal('.875'), 'seven eighths', '.875 String');
is(cardinal(''), 'zero', '"" String');
is(cardinal('-35/12', :improper ), 'negative thirty-five twelfths', '-35/12 String improper');
is(cardinal('-35/12', :denominator(24) ), 'negative two and twenty-two twenty-fourths', '-35/12 String common');
is(cardinal('-35/12', :denominator(24), :improper), 'negative seventy twenty-fourths', '-35/12 String common improper');

is(cardinal(2.5e-2), 'two point five times ten to the negative second', '2.5e-2 Num');
is(cardinal(2.5e+2), 'two point five times ten to the second', '2.5e+2 Num');
is(cardinal(-2.5e+2), 'negative two point five times ten to the second', '-2.5e+2Num');
is(cardinal(2.5e+02), 'two point five times ten to the second', '2.5e+02 Num');
is(cardinal(1/1.0e4), 'one times ten to the negative fourth', '1/1.0e4 Num');
is(cardinal(6.022e23), 'six point zero two two times ten to the twenty-third', '6.022e23 Num');
is(cardinal(0e0), 'zero', '0e0 Num');
is(cardinal(π), 'three point one four one five nine two six five three five eight nine seven nine', 'π Num');

is(cardinal(True), 'one', 'True Bool');
is(cardinal(False), 'zero', 'False Bool');

is(cardinal(-2.5+0i), 'negative two and one half', '-2.5+0i complex with out imaginary part');

#dies-ok({ cardinal() }, 'Dies if no parameter is passed'); # compile time error
dies-ok({ cardinal(1+1i) }, '1+1i Dies on complex with imaginary part');
dies-ok({ cardinal(1e309) }, '1e309 Dies on overflow');

done-testing();
