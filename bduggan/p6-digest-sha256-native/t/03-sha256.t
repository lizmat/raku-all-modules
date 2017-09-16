use Digest::SHA256::Native;

use Test;

# simple
is sha256('hi').map({.fmt('%02x')}).join, '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4', 'match for "hi"';

done-testing;
