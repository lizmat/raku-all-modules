use v6;
use Test;
use Lingua::EN::Numbers::Cardinal;

plan *;

is((join ', ', (1..10)».&cardinal), 'one, two, three, four, five, six, seven, eight, nine, ten', 'Int list');

is(cardinal(0), 'zero', 'Int');
is(cardinal(-1), 'negative one', 'Int');
is(cardinal(-1008), 'negative one thousand, eight', 'Int');
is(cardinal(10019), 'ten thousand, nineteen', 'Int');
is(cardinal(-1234567812), 'negative one billion, two hundred thirty-four million, five hundred sixty-seven thousand, eight hundred twelve', 'Int');
is(cardinal(42000), 'forty-two thousand', 'Int');
is(cardinal(198723483017417), 'one hundred ninety-eight trillion, seven hundred twenty-three billion, four hundred eighty-three million, seventeen thousand, four hundred seventeen', 'Int');


is((join ', ', map {cardinal($_/8)}, 0..8),
  'zero, one eighth, one quarter, three eighths, one half, five eighths, three quarters, seven eighths, one', 'Rat list');

is((join ', ', map {cardinal($_/8, common => 8) }, 0..8),
  'zero, one eighth, two eighths, three eighths, four eighths, five eighths, six eighths, seven eighths, one', 'Rat list common');

 {
      my @t = ( 'one', 'one tenth', 'one hundredth', 'one thousandth',
            'one ten thousandth', 'one one hundred thousandth',
            'one millionth', 'one ten millionth', 'one one hundred millionth',
            'one billionth', 'one ten billionth', 'one one hundred billionth',
            'one trillionth'
      );
      for 0..12 -> $d {
         is( cardinal( 1 / 10 ** $d ), @t[$d], 'ones' )
     }
 }

is(cardinal(3/16), 'three sixteenths', 'Rat');
is(cardinal(1/50), 'one fiftieth', 'Rat');
is(cardinal(1/101), 'one one hundred first', 'Rat');
is(cardinal(7/150), 'seven one hundred fiftieths', 'Rat');

is(cardinal(15/1000), 'three two hundredths', 'Rat');
is(cardinal(15/1000, common => 1000), 'fifteen thousandths', 'Rat common');
is(cardinal(15/1000, :common(1000)), 'fifteen thousandths', 'Rat common');
is(cardinal(27/16, :common(32), :improper), 'fifty-four thirty-seconds', 'Rat common improper');

is(cardinal(7/2), 'three and one half', 'Rat');
is(cardinal(7/2, :improper), 'seven halves', 'Rat improper');
is(cardinal(-7/2, :improper), 'negative seven halves', 'Rat improper');
is(cardinal(15/4, :improper), 'fifteen quarters', 'Rat improper');
is(cardinal(15/4), 'three and three quarters', 'Rat');

is(cardinal(97873/10000000),
  'ninety-seven thousand, eight hundred seventy-three ten millionths', 'Rat separator');
is(cardinal(97873/10000000, separator => '/'),
  'ninety-seven thousand, eight hundred seventy-three/ten millionths', 'Rat separator');
is(cardinal(17/57, separator => '/'), 'seventeen/fifty-sevenths', 'Rat separator');

is(cardinal(1/100.FatRat), 'one hundredth', 'FatRat');
is(cardinal(-1/1000.FatRat), 'negative one thousandth', 'FatRat');
is(cardinal(1/10000.FatRat), 'one ten thousandth', 'FatRat');
is(cardinal(-1/1000000.FatRat), 'negative one millionth', 'FatRat');

is(cardinal('12'), 'twelve', 'String');
is(cardinal('-123'), 'negative one hundred twenty-three', 'String');
is(cardinal('12/34'), 'six seventeenths', 'String');
is(cardinal('-12/34'), 'negative six seventeenths', 'String');
is(cardinal('-35/12'), 'negative two and eleven twelfths', 'String');
is(cardinal('.875'), 'seven eighths', 'String');
is(cardinal(''), 'zero', 'String');
is(cardinal('-35/12', :improper ), 'negative thirty-five twelfths', 'String improper');
is(cardinal('-35/12', :common(24) ), 'negative two and twenty-two twenty-fourths', 'String common');
is(cardinal('-35/12', :common(24), :improper), 'negative seventy twenty-fourths', 'String common improper');

is(cardinal(2.5e-2), 'one fortieth', 'Num');
is(cardinal(2.5e+2), 'two hundred fifty', 'Num');
is(cardinal(-2.5e+2), 'negative two hundred fifty', 'Num');
is(cardinal(1/1.0e4), 'one ten thousandth', 'Num');

is(cardinal(True), 'one', 'Bool');
is(cardinal(False), 'zero', 'Bool');

is(cardinal(-2.5+0i), 'negative two and one half', 'complex with out imaginary part');

#dies-ok({ cardinal() }, 'Dies if no parameter is passed'); # compile time error
dies-ok({ cardinal(1+1i) }, 'Dies on complex with imaginary part');
dies-ok({ cardinal(1e306) }, 'Dies on overflow');

done-testing();
