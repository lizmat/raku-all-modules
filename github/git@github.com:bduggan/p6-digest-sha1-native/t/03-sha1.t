use Digest::SHA1::Native;

use Test;

# simple
is sha1('hi').map({.fmt('%02x')}).join, 'c22b5f9178342609428d6f51b2c5af4c0bde6a42', 'match for "hi"';

done-testing;
