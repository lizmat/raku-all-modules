use Digest::SHA1::Native;
use Test;

is sha1-hex( ('z' x 10000) ),  '8ae70c86655f6edc2c32923a7d0b73aea813ed6d', 'long string';

done-testing;
