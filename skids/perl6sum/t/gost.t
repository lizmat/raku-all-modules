use v6;
use lib	'./lib';

use Test;

# These test vectors are a punt -- just the stuff from wikipedia for now

use Sum::GOST;
use Sum::libmhash;
use Sum::librhash;

if $Sum::librhash::up {
   plan 26;
}
# mhash GOST implementation is broken.  Kept for if it is ever fixed.
#elsif $Sum::libmhash::up {
#   plan 13;
#   diag "Only testing libmhash functionality as librhash not working.";
#}
else {
   plan 2;
   diag "No libmhash or librhash working, skipping most tests.";
}

ok 1,'We use Sum::GOST and we are still alive';

# With no pure Perl6 implementation, this should die
eval_dies_ok "class G1p does Sum::GOST[:!recourse] does Sum::Marshal::Raw { }", "Attempt to use nonexistant pure-Perl6 code dies.";

exit unless $Sum::librhash::up; # or $Sum::libmhash::up;

my $recourse = "librhash";
#$recourse = "libmhash" unless $Sum::librhash::up;
class G1 does Sum::GOST does Sum::Marshal::Raw { };
my G1 $s .= new();
is $s.recourse, $recourse, "Correct recourse for GOST with default sbox";
ok $s.WHAT === G1, 'We create a Sum::GOST class and object';

is G1.new.finalize("The quick brown fox jumps over the lazy dog".encode("ascii")).Int.base(16).lc, "77b7fa410c9ac58a25f49bca7d0468c9296529315eaca76bd1a10f376d1f4294", "GOST with test sbox, wikipedia test vector #1";
is G1.new.finalize("The quick brown fox jumps over the lazy cog".encode("ascii")).Int.base(16).lc, "a3ebc4daaab78b0be131dab5737a7f67e602670d543521319150d2e14eeec445", "GOST with test sbox, wikipedia test vector #2";
is G1.new.finalize("This is message, length=32 bytes".encode("ascii")).Int.base(16).lc, "b1c466d37519b82e8319819ff32595e047a28cb6f83eff1c6916a815a637fffa", "GOST with test sbox, wikipedia test vector #3";
is G1.new.finalize("Suppose the original message has length = 50 bytes".encode("ascii")).Int.base(16).lc, "471aba57a60a770d3a76130635c1fbea4ef14de51f78b4ae57dd893b62f55208", "GOST with test sbox, wikipedia test vector #5";
is G1.new.finalize("".encode("ascii")).Int.base(16).lc, "ce85b99cc46752fffee35cab9a7b0278abb4c2d2055cff685af4912c49490f8d", "GOST with test sbox, wikipedia test vector #6";
is G1.new.finalize("a".encode("ascii")).Int.base(16).lc, "d42c539e367c66e9c88a801f6649349c21871b4344c6a573f849fdce62f314dd", "GOST with test sbox, wikipedia test vector #7";
is G1.new.finalize("message digest".encode("ascii")).Int.base(16).lc, "ad4434ecb18f2c99b60cbe59ec3d2469582b65273f48de72db2fde16a4889a4d", "GOST with test sbox, wikipedia test vector #8";
is G1.new.finalize(("U" x 128).encode("ascii")).Int.base(16).lc, "53a3a3ed25180cef0c1d85a074273e551c25660a87062a52d926a9e8fe5733a4", "GOST with test sbox, wikipedia test vector #9";
is G1.new.finalize(("a" x 1000000).encode("ascii")).Int.base(16).lc, "5c00ccc2734cdd3332d3d4749576e3c1a7dbaf0e7ea74e9fa602413c90a129fa", "GOST with test sbox, wikipedia test vector #10";

exit unless $Sum::librhash::up;

class G2 does Sum::GOST[:sbox<CryptoPro>] does Sum::Marshal::Raw { };
my G2 $s2 .= new();
$recourse = "librhash";
is $s2.recourse, $recourse, "Correct recourse for GOST with CryptoPro sbox";
ok $s2.WHAT === G2, 'We create a Sum::GOST class and object';

is G2.new.finalize("The quick brown fox jumps over the lazy dog".encode("ascii")).Int.base(16).lc, "9004294a361a508c586fe53d1f1b02746765e71b765472786e4770d565830a76", "GOST with CryptoPro sbox, wikipedia test vector #1";
is G2.new.finalize("abc".encode("ascii")).Int.base(16).lc, "b285056dbf18d7392d7677369524dd14747459ed8143997e163b2986f92fd42c", "GOST with CryptoPro sbox, wikipedia test vector #2";
is G2.new.finalize("This is message, length=32 bytes".encode("ascii")).Int.base(16).lc, "2cefc2f7b7bdc514e18ea57fa74ff357e7fa17d652c75f69cb1be7893ede48eb", "GOST with CryptoPro sbox, wikipedia test vector #3";
is G2.new.finalize("Suppose the original message has length = 50 bytes".encode("ascii")).Int.base(16).lc, "c3730c5cbccacf915ac292676f21e8bd4ef75331d9405e5f1a61dc3130a65011", "GOST with CryptoPro sbox, wikipedia test vector #5";
is G2.new.finalize("".encode("ascii")).Int.base(16).lc, "981e5f3ca30c841487830f84fb433e13ac1101569b9c13584ac483234cd656c0", "GOST with CryptoPro sbox, wikipedia test vector #6";
is G2.new.finalize("a".encode("ascii")).Int.base(16).lc, "e74c52dd282183bf37af0079c9f78055715a103f17e3133ceff1aacf2f403011", "GOST with CryptoPro sbox, wikipedia test vector #7";
is G2.new.finalize("message digest".encode("ascii")).Int.base(16).lc, "bc6041dd2aa401ebfa6e9886734174febdb4729aa972d60f549ac39b29721ba0", "GOST with CryptoPro sbox, wikipedia test vector #8";
is G2.new.finalize(("U" x 128).encode("ascii")).Int.base(16).lc, "1c4ac7614691bbf427fa2316216be8f10d92edfd37cd1027514c1008f649c4e8", "GOST with CryptoPro sbox, wikipedia test vector #9";
is G2.new.finalize(("a" x 1000000).encode("ascii")).Int.base(16).lc, "8693287aa62f9478f7cb312ec0866b6c4e4a0f11160441e8f4ffcd2715dd554f", "GOST with CryptoPro sbox, wikipedia test vector #10";
is G2.new.finalize("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".encode("ascii")).Int.base(16).lc, "73b70a39497de53a6e08c67b6d4db853540f03e9389299d9b0156ef7e85d0f61", "GOST with CryptoPro sbox, wikipedia test vector #11";
is G2.new.finalize(("12345678901234567890123456789012345678901234567890123456789012345678901234567890").encode("ascii")).Int.base(16).lc, "6bc7b38989b28cf93ae8842bf9d752905910a7528a61e5bce0782de43e610c90", "GOST with CryptoPro sbox, wikipedia test vector #12";

