use v6;
use Test;
use CSS::Properties::Units :cm, :in, :mm, :pt, :px, :pc, :ops;

my $r = 1pt +css 2pt;
is $r, '3', 'pt +css pt';
is $r.type, 'pt', 'pt +css pt';

$r +css= 3pt;
is $r, '6', 'pt +css= pt';
is $r.type, 'pt', 'pt +css= pt';

$r = 1pt +css 1.76389mm;
is '%0.2f'.sprintf($r), '6.00', 'pt +css mm';
is $r.type, 'pt', 'pt +css mm';

$r = 1pt +css 1.76389cm;
is '%0.2f'.sprintf($r), '51.00', 'pt +css mm';

$r = 12pt -css 0.138889in;
is '%0.2f'.sprintf($r), '2.00', 'pt -css in';

is '%0.2f'.sprintf(0pt +css 1in), '72.00', 'pt +css in';
is '%0.2f'.sprintf(1pt +css 10px), '8.50', 'pt +css px';
is '%0.2f'.sprintf(2pt +css 1pc), '14.00', 'pt +css pc';

done-testing;
