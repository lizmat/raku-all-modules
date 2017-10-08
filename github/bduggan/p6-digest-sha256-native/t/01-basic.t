use Digest::SHA256::Native;

use Test;

# simple
is sha256-hex('hi'), '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4', 'match for "hi"';
is sha256-hex('hi'.encode), '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4', 'match for "hi".encode';

is sha256-hex(Buf.new(246,235,108)), '93763db1cdd44cc9b3e6b08c86061cc2b3fb295cfdd945fd3ff5e683235f3368', 'sha256 of buf';
is sha256-hex(Blob.new(246,235,108)), '93763db1cdd44cc9b3e6b08c86061cc2b3fb295cfdd945fd3ff5e683235f3368', 'sha256 of blob';

is sha256-hex("Hello World".encode), 'a591a6d40bf420404a011733cfb7b190d62c65bf0bcda32b57b277d9ad9f146e', "sha256";
is sha256-hex("ab\x[0]c"), "6c032e631d39a14d85aff7e319546af701e26c97b57ca95fbfe9c6ba855f67bf", "sha256 null bytes";

# example from wikipedia
is sha256-hex(""), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", "empty string";

# FIPS PUB 180-2 example B.2
is sha256-hex("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
              "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1", 'FIPS example';

# /* FIPS PUB 180.1 example B.3 */
is sha256-hex('a' x 1_000_000),
    'cdc76e5c9914fb9281a1c7e284d73e67f1809a48a497200e046d39ccc7112cd0', 'fips example';

done-testing;
