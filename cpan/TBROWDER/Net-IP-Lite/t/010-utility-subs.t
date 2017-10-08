use v6;
use Test;

use Net::IP::Lite :util;

# base conversions
is hexchar2dec('a'), 10;
is hexchar2bin('a'), '1010';

is hex2dec('ff'), 255;
is hex2dec('ff', 5), '00255';

is bin2dec('11'), 3;
is bin2dec('11', 4), '0003';

is bin2hex('00001010'), 'a';
is bin2hex('11', 4), '0003';

is dec2hex(10), 'a';
is dec2hex(10, 3), '00a';

is hex2bin('ff'), '11111111';
is hex2bin('ff', 10), '0011111111';

is dec2bin(10), '1010';
is dec2bin(10, 5), '01010';

# miscellaneous
is count-substrs('23:::', '::'), 2;
is count-substrs('d:efa33:23:::', ':'), 5;
is count-substrs('d-:efa33:23:-::', '-:'), 2;

done-testing;
