use v6;
use experimental :pack;
use Digest::MurmurHash3;
use Test;

my Str $key  = "hogefugafoobar";
my Int $seed = 12345678;

subtest {

    # ~0 for type uint32 should be 4294967295
    # but turns out to be -1 in CArray[uint32]!
    is Digest::MurmurHash3::fix-sign-bit(-1), 4294967295;

}, 'Test fix-sign-bit';

subtest {
    my Int $result = murmurhash3_32($key, $seed);

    is $result, 463552099;

}, 'Test murmurhash3_32';

subtest {
    my Buf $result = murmurhash3_32_hex($key, $seed);

    is $result.unpack('H4'), '633ea11b';

}, 'Test murmurhash3_32_hex';

subtest {
    my Int @result = murmurhash3_128($key, $seed);

    is @result.elems, 4;
    is-deeply @result, Array[Int].new(
        1512736128,
        3528938480,
        3633978259,
        481906499,
    );

}, 'Test murmurhash3_128';

subtest {
    my Buf $result = murmurhash3_128_hex($key, $seed);

    is $result.unpack('H16'), '80852a5af05357d2931b9ad8434fb91c';

}, 'Test murmurhash3_128_hex';

done-testing;
