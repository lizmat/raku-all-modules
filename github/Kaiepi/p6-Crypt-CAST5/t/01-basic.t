use v6.d;
use Crypt::CAST5;
use Test;

my Array constant TESTS = [{
    name       => '128 bit key',
    key        => Blob.new(1, 35, 69, 103, 18, 52, 86, 120, 35, 69, 103, 137, 52, 86, 120, 154),
    plaintext  => Blob.new(1, 35, 69, 103, 137, 171, 205, 239),
    ciphertext => Blob.new(35, 139, 79, 229, 132, 126, 68, 178)
}, {
    name       => '80 bit key',
    key        => Blob.new(1, 35, 69, 103, 18, 52, 86, 120, 35, 69),
    plaintext  => Blob.new(1, 35, 69, 103, 137, 171, 205, 239),
    ciphertext => Blob.new(235, 106, 113, 26, 44, 2, 39, 27)
}, {
    name       => '40 bit key',
    key        => Blob.new(1, 35, 69, 103, 18),
    plaintext  => Blob.new(1, 35, 69, 103, 137, 171, 205, 239),
    ciphertext => Blob.new(122, 200, 22, 209, 110, 155, 48, 46)
}];

plan (+TESTS * 2) + 2;

dies-ok {
    Crypt::CAST5.new: Blob.new
}, 'Cannot construct an instance with too small a key';

dies-ok {
    Crypt::CAST5.new: Blob.allocate: 69
}, 'Cannot construct an instance with too large a key';

for TESTS -> %test {
    my Crypt::CAST5 $cast5   .= new: %test<key>;
    my Blob         $encoded  = $cast5.encode: %test<plaintext>;
    my Blob         $decoded  = $cast5.decode: $encoded;
    cmp-ok $encoded, 'eqv', %test<ciphertext>, "%test<name> test encrypts its plaintext with the given key properly";
    cmp-ok $decoded, 'eqv', %test<plaintext>, "%test<name> test decrypts its ciphertext with the given key properly";
}

# vim: ft=perl6 sw=4 ts=4 sts=4 expandtab
