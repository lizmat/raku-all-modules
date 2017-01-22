use v6;
use Test;
use CSS::Declarations::Units;

my $r = 1pt + 2pt;
is $r, '3', 'pt + pt';
is $r.type, 'pt', 'pt + pt';

$r = 1pt + 1.76389mm;
is '%0.2f'.sprintf($r), '6.00', 'pt + mm';
is $r.type, 'pt', 'pt + mm';

$r = 1pt + 1.76389cm;
is '%0.2f'.sprintf($r), '51.00', 'pt + mm';

$r = 12pt - 0.138889in;
is '%0.2f'.sprintf($r), '2.00', 'pt - in';

is '%0.2f'.sprintf(0pt + 1in), '72.00', 'pt + in';
is '%0.2f'.sprintf(1pt + 10px), '8.50', 'pt + px';
is '%0.2f'.sprintf(2pt + 1pc), '14.00', 'pt + pc';

done-testing;
