use Test;
use Test::When <extended>;

use Munge;

my $ctx = Munge::Context.new;

plan 10;

subtest 'Munge::Cipher',
{
    plan 6;

    is $ctx.cipher(MUNGE_CIPHER_NONE), MUNGE_CIPHER_NONE,
        'MUNGE_CIPHER_NONE';

    is $ctx.cipher(MUNGE_CIPHER_DEFAULT), MUNGE_CIPHER_DEFAULT,
        'MUNGE_CIPHER_DEFAULT';

    is $ctx.cipher(MUNGE_CIPHER_BLOWFISH), MUNGE_CIPHER_BLOWFISH,
        'MUNGE_CIPHER_BLOWFISH';

    is $ctx.cipher(MUNGE_CIPHER_CAST5), MUNGE_CIPHER_CAST5,
        'MUNGE_CIPHER_BLOWFISH';

    is $ctx.cipher(MUNGE_CIPHER_AES128), MUNGE_CIPHER_AES128,
        'MUNGE_CIPHER_AES128';

    is $ctx.cipher(MUNGE_CIPHER_AES256), MUNGE_CIPHER_AES256,
        'MUNGE_CIPHER_AES256';
}

subtest 'String Cipher',
{
    plan 6;

    is $ctx.cipher('NONE'), MUNGE_CIPHER_NONE,
        'MUNGE_CIPHER_NONE';

    is $ctx.cipher('DEFAULT'), MUNGE_CIPHER_DEFAULT,
        'MUNGE_CIPHER_DEFAULT';

    is $ctx.cipher('BLOWFISH'), MUNGE_CIPHER_BLOWFISH,
        'MUNGE_CIPHER_BLOWFISH';

    is $ctx.cipher('CAST5'), MUNGE_CIPHER_CAST5,
        'MUNGE_CIPHER_BLOWFISH';

    is $ctx.cipher('AES128'), MUNGE_CIPHER_AES128,
        'MUNGE_CIPHER_AES128';

    is $ctx.cipher('AES256'), MUNGE_CIPHER_AES256,
        'MUNGE_CIPHER_AES256';
}

subtest 'Munge::MAC',
{
    plan 6;

    is $ctx.MAC(MUNGE_MAC_DEFAULT), MUNGE_MAC_DEFAULT, 'MUNGE_MAC_DEFAULT';

    is $ctx.MAC(MUNGE_MAC_MD5), MUNGE_MAC_MD5, 'MUNGE_MAC_MD5';

    is $ctx.MAC(MUNGE_MAC_SHA1), MUNGE_MAC_SHA1, 'MUNGE_MAC_SHA1';

    is $ctx.MAC(MUNGE_MAC_RIPEMD160), MUNGE_MAC_RIPEMD160, 'MUNGE_MAC_RIPEMD160';

    is $ctx.MAC(MUNGE_MAC_SHA256), MUNGE_MAC_SHA256, 'MUNGE_MAC_SHA256';

    is $ctx.MAC(MUNGE_MAC_SHA512), MUNGE_MAC_SHA512, 'MUNGE_MAC_SHA512';
}

subtest 'String MAC',
{
    plan 6;

    is $ctx.MAC('DEFAULT'), MUNGE_MAC_DEFAULT, 'MUNGE_MAC_DEFAULT';

    is $ctx.MAC('MD5'), MUNGE_MAC_MD5, 'MUNGE_MAC_MD5';

    is $ctx.MAC('SHA1'), MUNGE_MAC_SHA1, 'MUNGE_MAC_SHA1';

    is $ctx.MAC('RIPEMD160'), MUNGE_MAC_RIPEMD160, 'MUNGE_MAC_RIPEMD160';

    is $ctx.MAC('SHA256'), MUNGE_MAC_SHA256, 'MUNGE_MAC_SHA256';

    is $ctx.MAC('SHA512'), MUNGE_MAC_SHA512, 'MUNGE_MAC_SHA512';
}

subtest 'Munge::Zip',
{
    plan 4;

    is $ctx.zip(MUNGE_ZIP_NONE), MUNGE_ZIP_NONE, 'MUNGE_ZIP_NONE';

    is $ctx.zip(MUNGE_ZIP_DEFAULT), MUNGE_ZIP_DEFAULT, 'MUNGE_ZIP_DEFAULT';

    is $ctx.zip(MUNGE_ZIP_BZLIB), MUNGE_ZIP_BZLIB, 'MUNGE_ZIP_BZLIB';

    is $ctx.zip(MUNGE_ZIP_ZLIB), MUNGE_ZIP_ZLIB, 'MUNGE_ZIP_ZLIB';
}

subtest 'String Zip',
{
    plan 4;

    is $ctx.zip('NONE'), MUNGE_ZIP_NONE, 'MUNGE_ZIP_NONE';

    is $ctx.zip('DEFAULT'), MUNGE_ZIP_DEFAULT, 'MUNGE_ZIP_DEFAULT';

    is $ctx.zip('BZLIB'), MUNGE_ZIP_BZLIB, 'MUNGE_ZIP_BZLIB';

    is $ctx.zip('ZLIB'), MUNGE_ZIP_ZLIB, 'MUNGE_ZIP_ZLIB';
}

subtest 'Time-To-Live (TTL)',
{
    plan 3;

    is $ctx.ttl(MUNGE_TTL_DEFAULT), MUNGE_TTL_DEFAULT, 'MUNGE_TTL_DEFAULT';

    is $ctx.ttl(MUNGE_TTL_MAXIMUM), MUNGE_TTL_MAXIMUM, 'MUNGE_TTL_MAXIMUM';

    is $ctx.ttl(17), 17, 'Set to number';
}

subtest 'uid-restriction',
{
    plan 2;

    is $ctx.uid-restriction(MUNGE_UID_ANY), MUNGE_UID_ANY, 'MUNGE_UID_ANY';

    is $ctx.uid-restriction(17), 17, 'uid set';
}

subtest 'gid-restriction',
{
    plan 2;

    is $ctx.gid-restriction(MUNGE_GID_ANY), MUNGE_GID_ANY, 'MUNGE_GID_ANY';

    is $ctx.gid-restriction(42), 42, 'gid set';
}

is $ctx.addr4, '0.0.0.0', 'addr4 not set yet';

done-testing;
