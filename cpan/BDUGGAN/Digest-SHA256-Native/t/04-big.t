use Digest::SHA256::Native;
use Test;

is sha256-hex( ('z' x 10000) ),  '0b722b8a96bfe84a3bd16d9d41cd2a1a4335e6b974d6ea0412bdeff4462e479f', 'long string';

done-testing;
