use Digest::SHA1::Native;
use Test;
plan 500;

# simple
for 1..500 {
    is sha1-hex('hi'), 'c22b5f9178342609428d6f51b2c5af4c0bde6a42', 'match for "hi"';
}
done-testing;
