use Test;
use lib 'lib';

plan 1;

use PackUnpack; pass "Import PackUnpack";

#dd parse-pack-template("a*x234N");
#dd pack("a*aa2",<a bb ccc>);
#dd pack("A* A* A*",<a bb ccc>);
#dd pack("Z*Z5Z2",<a bb ccc>);
#dd unpack("U*",pack("U3",97,0xe7,0x1F4A9));
#dd pack("h*","2143");
#dd pack("CH*",42,"1234");
#dd pack("N*",1,2,3);
#dd pack("N*",4,5,6);
#dd pack("x5");


