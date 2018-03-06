use v6;
use Test;
plan 7;

use CSS::Declarations::Units :pt, :px, :pc, :in;
use CSS::Declarations :measure;

is measure(10pt), 10;

is '%0.2f'.sprintf(measure(1in)), '72.00', 'measure(in)';
is '%0.2f'.sprintf(measure(10px)), '7.50', 'measure(px)';
is '%0.2f'.sprintf(measure(1pc)), '12.00', 'measure(pc)';
is '%0.2f'.sprintf(measure(1 does CSS::Declarations::Units::Type["em"])), '12.00', 'measure(em)';
is '%0.2f'.sprintf(measure(1 does CSS::Declarations::Units::Type["em"], :em(15))), '15.00', 'measure(em)';
is '%0.2f'.sprintf(measure(1 does CSS::Declarations::Units::Type["ex"])), '9.00', 'measure(ex)';

done-testing;
