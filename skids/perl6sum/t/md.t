use v6;
use lib <blib/lib lib>;

use Test;

plan 75;

use Sum;
use Sum::libcrypto;
use Sum::librhash;
use Sum::libmhash;
use Sum::MD;

ok 1,'We use Sum::MD and we are still alive';

my $c_or_r_or_m_or_p = "libcrypto";
my $r_or_m_or_p = "librhash";
unless $Sum::libcrypto::up {
    $c_or_r_or_m_or_p := $r_or_m_or_p;
}
unless $Sum::librhash::up {
    $r_or_m_or_p = "libmhash";
    unless $Sum::libmhash::up {
        $r_or_m_or_p = "Perl6";
    }
}

# First test a pure Perl 6 implementation
class MD4t does Sum::MD4[:!recourse] does Sum::Marshal::Raw { };
my MD4t $s .= new();
ok $s.WHAT === MD4t, 'We create a MD4 class and object';

given (MD4t.new()) {
is .recourse, "Perl6", "MD4[:!recourse] claims recourse 'Perl6'";
is .size, 128, "MD4.size is correct";
is +.finalize(buf8.new()),
   0x31d6cfe0d16ae931b73c59d7e0c089c0,
   "MD4 of an empty buffer is correct.";
}
is +MD4t.new().finalize(buf8.new(97)),
   0xbde52cb31de33e46245e05fbdbd6fb24,
   "MD4 of a 1-byte buffer is correct.";
is +MD4t.new().finalize(buf8.new(97 xx 55)),
   0xc889c81dd86c4d2e025778944ea02881,
   "MD4 of a 55-byte buffer is correct.";
is +MD4t.new().finalize(buf8.new(97 xx 56)),
   0xd5f9a9e9257077a5f08b0b92f348b0ad,
   "MD4 of a 56-byte buffer is correct.";
is +MD4t.new().finalize(buf8.new(97 xx 64)),
   0x52f5076fabd22680234a3fa9f9dc5732,
   "MD4 of a 64-byte buffer is correct.";
is +MD4t.new().finalize(buf8.new(),True),
   0x15f8f7419944ac564526a3c65da2c5f3,
   "MD4 of a 1-bit buffer is correct.";
is +MD4t.new().finalize(buf8.new(),True,False,True,False,True,False,False),
   0x81d0ea938ae2ad56f51c1228b5d26d47,
   "MD4 of a 7-bit buffer is correct.";
is +MD4t.new().finalize(buf8.new(97),True),
   0x6b9ffb14ef505495fa6323ffcac69967,
   "MD4 of a 9-bit buffer is correct.";
is +MD4t.new().finalize(buf8.new(97 xx 55),True,False,True,False,True,False,False),
   0xbde1a4654c6b80bff32ee4a0fde4d5d5,
   "MD4 of a 447-bit buffer is correct.";
is +MD4t.new().finalize(buf8.new(97 xx 56),True),
   0x70489fa63a69a637c09c4999e994877c,
   "MD4 of a 449-bit buffer is correct.";
is +MD4t.new().finalize(buf8.new(97 xx 63),True,False,True,False,True,False,False),
   0x0719b5d879deafc63150bc5aa45ba714,
   "MD4 of a 511-bit buffer is correct.";

given (MD4t.new()) {
  .push(buf8.new(97 xx 56),True);
  is .Buf.values.fmt("%2.2x"), "70 48 9f a6 3a 69 a6 37 c0 9c 49 99 e9 94 87 7c", "MD4 Buf method works (and finalizes)";
}

class MD4tp does Sum::MD4 does Sum::Marshal::Raw { };
my MD4tp $stp .= new();
ok $stp.WHAT === MD4tp, 'We create a MD4 class and object';

given (MD4tp.new()) {
is .recourse, $r_or_m_or_p, "MD4 uses expected recourse";
is .size, 128, "MD4.size is correct. (:recourse<$r_or_m_or_p>)";
is +.finalize(buf8.new()),
   0x31d6cfe0d16ae931b73c59d7e0c089c0,
   "MD4 of an empty buffer is correct. (:recourse<$r_or_m_or_p>)";
}
is +MD4tp.new().finalize(buf8.new(97)),
   0xbde52cb31de33e46245e05fbdbd6fb24,
   "MD4 of a 1-byte buffer is correct. (:recourse<$r_or_m_or_p>)";
is +MD4tp.new().finalize(buf8.new(97 xx 55)),
   0xc889c81dd86c4d2e025778944ea02881,
   "MD4 of a 55-byte buffer is correct. (:recourse<$r_or_m_or_p>)";
is +MD4tp.new().finalize(buf8.new(97 xx 56)),
   0xd5f9a9e9257077a5f08b0b92f348b0ad,
   "MD4 of a 56-byte buffer is correct. (:recourse<$r_or_m_or_p>)";
is +MD4tp.new().finalize(buf8.new(97 xx 64)),
   0x52f5076fabd22680234a3fa9f9dc5732,
   "MD4 of a 64-byte buffer is correct. (:recourse<$r_or_m_or_p>)";

class MD4dwim does Sum::MD4[:!recourse] does Sum::Marshal::Block[] { }
my MD4dwim $dwim .= new();
ok $dwim.WHAT === MD4dwim, 'We create a dwimmy Block MD4 class and object';

is +$dwim.finalize(('0123456789' x 100).ords), 0x895ffd5f1acfe6f760c777e7883605e9, "MD4 of 1000 Ints is correct";

$dwim .= new();

is +$dwim.finalize(buf8.new((0x30..0x39) xx 100)), 0x895ffd5f1acfe6f760c777e7883605e9, "MD4 of 8000-bit Buf is correct";

class MD4ext does Sum::MD4ext does Sum::Marshal::Raw { };
is MD4ext.size, 256, "extended MD4 .size is correct.  And a class method.";
todo "Need extended MD4 test vector", 1;
is +MD4ext.new().finalize(buf8.new(97 xx 55)),
   0x0,
   "Extended MD4 works.";

class MD5t does Sum::MD5 does Sum::Marshal::Raw { };
my MD5t $md5 .= new();
ok $md5.WHAT === MD5t, 'We create an MD5 class and object';

given (MD5t.new()) {
  is .recourse, $c_or_r_or_m_or_p, "MD5 uses expected :recourse<$c_or_r_or_m_or_p>";
  is .size, 128, "MD5.size is correct";
  is +.finalize(buf8.new()),
     0xd41d8cd98f00b204e9800998ecf8427e,
     "MD5 of an empty buffer is correct.";
  is .Buf.values.fmt("%x"), "d4 1d 8c d9 8f 0 b2 4 e9 80 9 98 ec f8 42 7e", "MD5 Buf method works";
}
# Since it uses the same buffering code as MD4 we don't need to test
# different lengths thoroughly, but a few more test vectors would be good.
is +MD5t.new().finalize(buf8.new(97 xx 64)),
   0x014842d480b571495a4a0363793f7367,
   "MD5 is correct (test vector 1).";

given (MD5t.new()) {
   .push(buf8.new(97 xx 64));
   .push(buf8.new(97 xx 64));
   is +.finalize(buf8.new(97 xx 56)), 0x63642b027ee89938c922722650f2eb9b,
   "MD5 is correct (test vector 2).";
}

class r160t does Sum::RIPEMD160[] does Sum::Marshal::Raw { };
my r160t $r160 .= new();
ok $r160.WHAT === r160t, 'We create a RIPEMD-160 class and object';

given (r160t.new()) {
  is .recourse, $c_or_r_or_m_or_p, "RIPEMD-160 uses expected :recourse<$c_or_r_or_m_or_p>";
  is .size, 160, "RIPEMD-160.size is correct";
  is +.finalize(buf8.new()),
     0x9c1185a5c5e9fc54612808977ee8f548b2258d31,
     "RIPEMD-160 of an empty buffer is correct.";
   is .Buf.values.fmt("%x"), "9c 11 85 a5 c5 e9 fc 54 61 28 8 97 7e e8 f5 48 b2 25 8d 31", "RIPEMD-160 Buf method works";
}
# Since it uses the same buffering code as MD4 we don't need to test
# different lengths thoroughly, but a few more test vectors would be good.
is +r160t.new().finalize(buf8.new(97 xx 64)),
   0x9dfb7d374ad924f3f88de96291c33e9abed53e32,
   "RIPEMD-160 is correct (test vector 1).";

given (r160t.new()) {
   .push(buf8.new(97 xx 64));
   .push(buf8.new(97 xx 64));
   is +.finalize(buf8.new(97 xx 56)), 0x52a7ad26b98c60e2f14e0863c1b58de525888b11,
   "RIPEMD-160 is correct (test vector 2).";
}

class r128t does Sum::RIPEMD128[] does Sum::Marshal::Raw { };
my r128t $r128 .= new();
ok $r128.WHAT === r128t, 'We create a RIPEMD-128 class and object';

given (r128t.new()) {
  is .recourse, "Perl6", "RIPEMD-128 uses expected :recourse<Perl6>";
  is .size, 128, "RIPEMD-128.size is correct";
  is +.finalize(buf8.new()),
     0xcdf26213a150dc3ecb610f18f6b38b46,
     "RIPEMD-128 of an empty buffer is correct.";
  is .Buf.values.fmt("%x"), "cd f2 62 13 a1 50 dc 3e cb 61 f 18 f6 b3 8b 46", "RIPEMD-128 Buf method works";
}
# Since it uses the same buffering code as MD4 we don't need to test
# different lengths thoroughly, but a few more test vectors would be good.
is +r128t.new().finalize(buf8.new(97 xx 64)),
   0x680716ac638f0d601982c696d37e5e56,
   "RIPEMD-128 is correct (test vector 1).";

given r128t.new() {
   .push(buf8.new(97 xx 64));
   .push(buf8.new(97 xx 64));
   is +.finalize(buf8.new(97 xx 56)), 0x481285089b4b03da9eeffc2721680354,
   "RIPEMD-128 is correct (test vector 2).";
}

class r320t does Sum::RIPEMD320[] does Sum::Marshal::Raw { };
my r320t $r320 .= new();
ok $r320.WHAT === r320t, 'We create a RIPEMD-320 class and object';

given (r320t.new()) {
  is .recourse, "Perl6", "RIPEMD-320 uses expected :recourse<Perl6>";
  is .size, 320, "RIPEMD-320.size is correct";
  is +.finalize(buf8.new()),
     0x22d65d5661536cdc75c1fdf5c6de7b41b9f27325ebc61e8557177d705a0ec880151c3a32a00899b8,
     "RIPEMD-320 of an empty buffer is correct.";
  is .Buf.values.fmt("%x"), "22 d6 5d 56 61 53 6c dc 75 c1 fd f5 c6 de 7b 41 b9 f2 73 25 eb c6 1e 85 57 17 7d 70 5a e c8 80 15 1c 3a 32 a0 8 99 b8", "RIPEMD-320 Buf method works";
}

# Since it uses the same buffering code as MD4 we don't need to test
# different lengths thoroughly, but a few more test vectors would be good.
is +r320t.new().finalize(buf8.new(97 xx 64)),
   0x6e815badcf69d2978caf8b8bbaba941239f9847d1ff140062484cb57a0745bccf21c427705fdd30d,
   "RIPEMD-320 is correct (test vector 1).";

given r320t.new() {
    .push(buf8.new(97 xx 64));
    .push(buf8.new(97 xx 64));
    is +.finalize(buf8.new(97 xx 56)),
   0x82c5b5ffb960376afb6e21b33bd2367197080dd9724f7e2947e1075347462e603649bca32ad1b824,
   "RIPEMD-320 is correct (test vector 2).";
}

class r256t does Sum::RIPEMD256[] does Sum::Marshal::Raw { };
my r256t $r256 .= new();
ok $r256.WHAT === r256t, 'We create a RIPEMD-256 class and object';

given (r256t.new()) {
  is .recourse, "Perl6", "RIPEMD-256 uses expected :recourse<Perl6>";
  is .size, 256, "RIPEMD-256.size is correct";
  is +.finalize(buf8.new()),
     0x02ba4c4e5f8ecd1877fc52d64d30e37a2d9774fb1e5d026380ae0168e3c5522d,
     "RIPEMD-256 of an empty buffer is correct.";
  is .Buf.values.fmt("%x"), "2 ba 4c 4e 5f 8e cd 18 77 fc 52 d6 4d 30 e3 7a 2d 97 74 fb 1e 5d 2 63 80 ae 1 68 e3 c5 52 2d", "RIPEMD-256 Buf method works";
}
# Since it uses the same buffering code as MD4 we don't need to test
# different lengths thoroughly, but a few more test vectors would be good.
is +r256t.new().finalize(buf8.new(97 xx 64)),
   0x8147678472c129cabb59f57f637c622ccd5707af80a583303e6dde7d0800ced6,
   "RIPEMD-256 is correct (test vector 1).";

given r256t.new() {
   .push(buf8.new(97 xx 64));
   .push(buf8.new(97 xx 64));
   is +.finalize(buf8.new(97 xx 56)),
   0x8e7bc719ca3cdbb9411e43f18955a1f305e7643a0ae20a7a01823e80090fcf37,
   "RIPEMD-256 is correct (test vector 2).";
}

class MD2t does Sum::MD2 does Sum::Marshal::Raw { };
my MD2t $s2 .= new();
ok $s2.WHAT === MD2t, 'We create a MD2 class and object';

given (MD2t.new()) {
is .size, 128, "MD2.size is correct";
is +.finalize(buf8.new()),
   0x8350e5a3e24c153df2275c9f80692773,
   "MD2 of an empty buffer is correct.";
}
is +MD2t.new().finalize(buf8.new(97)),
   0x32ec01ec4a6dac72c0ab96fb34c0b5d1,
   "MD2 of a 1-byte buffer is correct.";
is +MD2t.new().finalize(buf8.new(97 xx 15)),
   0xa1379a1027d0d29af98200799b8d5d8e,
   "MD2 of a 15-byte buffer is correct.";
is +MD2t.new().finalize(buf8.new(97 xx 16)),
   0xb437ae50feb09a37c16b4c605cd642da,
   "MD2 of a 16-byte buffer is correct.";
is +MD2t.new().finalize(buf8.new(97 xx 16), buf8.new(97)),
   0xdbf15a5fdfd6f7e9ece27d5e310c58ed,
   "MD2 of a 17-byte buffer is correct.";
given (MD2t.new()) {
  .push(buf8.new(97 xx 16), buf8.new(97));
  is .Buf.values.fmt("%2.2x"), "db f1 5a 5f df d6 f7 e9 ec e2 7d 5e 31 0c 58 ed", "MD2 Buf method works (and finalizes)";
}

class MD2d does Sum::MD2 does Sum::Marshal::Block[:elems(16)] { };
my MD2d $s3 .= new();
ok $s3.WHAT === MD2d, 'We create a dwimmy Block MD2 class and object';

is +$s3.finalize(buf8.new(97 xx 17)), 0xdbf15a5fdfd6f7e9ece27d5e310c58ed,
   "MD2 of a 17-byte buffer using Sum::Marshal::Block.";

# Now grab the code in the synopsis from the POD and make sure it runs.
# This is currently complete hackery but might improve when pod support does.
# And also an outputs_ok Test.pm function that redirects $*OUT might be nice.
class sayer {
    has $.accum is rw = "";
    method print (*@s) { $.accum ~= [~] @s }
}
my sayer $p .= new();
{ temp $*OUT = $p; EVAL $Sum::MD::Doc::synopsis; }
is $p.accum, $Sum::MD::Doc::synopsis.comb(/<.after \x23\s> (<.ws> <.xdigit>+)+/).join("\n") ~ "\n", 'Code in manpage synopsis actually works';

