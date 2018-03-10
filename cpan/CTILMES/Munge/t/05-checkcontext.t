use Test;
use Test::When <extended>;

use Munge;

plan 7;

ok my $m = Munge.new(cipher => 'blowfish', MAC => 'sha256', zip => 'zlib'),
    'new';

ok my $encoded = $m.encode('foo'), 'encode';

is $m.decode($encoded), 'foo', 'decode';

is $m.cipher, MUNGE_CIPHER_BLOWFISH, 'Cipher';

is $m.MAC, MUNGE_MAC_SHA256, 'MAC';

is $m.uid, +$*USER, 'uid';

is $m.gid, +$*GROUP, 'gid';

done-testing;
