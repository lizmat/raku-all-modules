use Digest::SHA1::Native;

use Test;

# simple
is sha1-hex('hi'), 'c22b5f9178342609428d6f51b2c5af4c0bde6a42', 'match for "hi"';
is sha1-hex('hi'.encode), 'c22b5f9178342609428d6f51b2c5af4c0bde6a42', 'match for "hi".encode';
is sha1-hex(Buf.new(246,235,108)), '29f19d798e4f28cbf28469468f9b1be56786af11', 'sha1 of buf';
is sha1-hex(Blob.new(246,235,108)), '29f19d798e4f28cbf28469468f9b1be56786af11', 'sha1 of blob';

# examples from nqp
is sha1-hex("Hello World".encode), '0a4d55a8d778e5022fab701977c5d840bbc486d0', "sha1";
is sha1-hex("ab\x[0]c"), "dbdd4f85d8a56500aa5c9c8a0d456f96280c92e5", "sha1 null bytes";

# examples from wikipedia
is sha1-hex("The quick brown fox jumps over the lazy dog"), '2fd4e1c67a2d28fced849ee1bb76e7391b93eb12', 'sentence 1';
is sha1-hex("The quick brown fox jumps over the lazy cog"), 'de9f2c7fd25e1b3afad3e85a0bd17d9b100db4b3', 'sentence 2';
is sha1-hex(''), 'da39a3ee5e6b4b0d3255bfef95601890afd80709', 'empty string';

# Examples from sha1.c self test
# FIPS PUB 180.1 example A.1
is sha1-hex('abc'), 'a9993e364706816aba3e25717850c26c9cd0d89d', 'abc';

# /* FIPS PUB 180.1 example A.2 */
is sha1-hex('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'),
   '84983e441c3bd26ebaae4aa1f95129e5e54670f1', 'fips example';

done-testing;
