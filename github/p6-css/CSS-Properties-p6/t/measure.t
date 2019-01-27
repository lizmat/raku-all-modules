use v6;
use Test;
plan 13;

use CSS::Properties::Units :pt, :px, :pc, :in, :vw, :vh;
use CSS::Properties;
my CSS::Properties $css .= new: :viewport-width(200pt), :viewport-height(100pt);
is '%0.2f'.sprintf($css.measure($css.viewport-width)), '200.00', '$css.measure($.viewport-width)';
is '%0.2f'.sprintf($css.measure($css.viewport-height)), '100.00', '$css.measure($.viewport-height)';

is $css.measure(10pt), 10, '$css.measure(pt)';

is '%0.2f'.sprintf($css.measure(10px)), '7.50', '$css.measure(px)';
is '%0.2f'.sprintf($css.measure(1pc)), '12.00', '$css.measure(pc)';
is '%0.2f'.sprintf($css.measure(1 does CSS::Properties::Units::Type["em"])), '12.00', '$css.measure(em)';
is '%0.2f'.sprintf($css.measure(1 does CSS::Properties::Units::Type["em"], :em(15))), '15.00', '$css.measure(em)';
is '%0.2f'.sprintf($css.measure(1 does CSS::Properties::Units::Type["ex"])), '9.00', '$css.measure(ex)';
is '%0.2f'.sprintf($css.measure(.1vw)), '20.00', '$css.measure(vw)';
is '%0.2f'.sprintf($css.measure(.1vh)), '10.00', '$css.measure(vh)';

# change base units
$css .= new: :units<pc>;
is '%0.2f'.sprintf($css.measure(1pc)), '1.00', '$css.measure(in)';
is '%0.2f'.sprintf($css.measure(1in)), '6.00', '$css.measure(in)';
is '%0.2f'.sprintf($css.measure(12pt)), '1.00', '$css.measure(in)';

done-testing;
