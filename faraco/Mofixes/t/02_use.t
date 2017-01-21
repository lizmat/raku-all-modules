use Test;
use Mofixes;

plan 8;

is mofact 6, 720,  '[Mo]mofact(factorial) is okay';
is mofactadd 6, 20, '[Mo]mofactadd is okay';
is mofactminus 6, -16, '[Mo]mofactminus is okay';
is mofactdivide 6, 0.005556, '[Mo]mofactdivide is okay';

is 6!, 720, '[Mo]!(factorial) is okay';
is 6!+, 20,	'[Mo]!+ is okay';
is 6!-, -16, '[Mo]!- is okay';
is 6!!d, 0.005556, '[Mo]!!/ is okay';


