use Test;

use lib 'lib';
use TinyCC::Bundled;
use TinyCC::Typeof;

plan 3;

is typeof(uint16), 'unsigned short', 'uint16';
is typeof(int32), 'int', 'int32';
is typeof(num32), 'float', 'num32';
