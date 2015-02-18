use v6;
use lib	'./lib';

use Test;

plan 70 + ?($*VM.name ne "parrot");

use Sum::SipHash;
ok(1,'We use Sum::SipHash and we are still alive');

class S does Sum::SipHash does Sum::Partial does Sum::Marshal::Method[:atype(Str) :method<ords>] { }
my S $s .= new(:key(0x000102030405060708090a0b0c0d0e0f));
is $s.size, 64, "SipHash.size works";
my $h = $s.finalize("Please to checksum this text");
is +$h, 0x5cabf2fe9143a691, "SipHash (StrOrds) computes expected value";
$h = $s.finalize(".");
is +$h, 0x4fe6afaef85fbad6, "append after finalization and get expected value";
is $s.partials("......")».Int, (0xf3009ba116623fd5, 0xb28753d8b488ae38, 0xfedd16cd7a81b334, 0x17241487941ee6da, 0xdc73124438fcb94d, 0x4c80530e3ead0ad7), "partials yields expected values across a w boundary";
is $s.Buf.values, (0x4c,0x80,0x53,0x0e,0x3e,0xad,0x0a,0xd7), "Buf method works";

# Now grab the code in the synopsis from the POD and make sure it runs.
# This is currently complete hackery but might improve when pod support does.
# And also an outputs_ok Test.pm function that redirects $*OUT might be nice.
class sayer {
    has $.accum is rw = "";
    method print (*@s) { $.accum ~= [~] @s }
}
my sayer $p .= new();
# Rakudo-p currently does not serialize $=pod in PIR compunits so skip this.
if ($*VM.name ne 'parrot') {
{ temp $*OUT = $p; EVAL $Sum::SipHash::Doc::synopsis; }
is $p.accum, $Sum::SipHash::Doc::synopsis.comb(/<.after \x23\s> (<.ws> <.xdigit>+)+/).join("\n") ~ "\n", 'Code in manpage synopsis actually works';
}

# These test vectors appear in Aumussen reference C implentation

# rakudo-m has trouble with this array as integers so we use strings
my @refvecs = <
726FDB47DD0E0E31 74F839C593DC67FD  D6C8009D9A94F5A 85676696D7FB7E2D
CF2794E0277187B7 18765564CD99A68D CBC9466E58FEE3CE AB0200F58B01D137
93F5F5799A932462 9E0082DF0BA9E4B0 7A5DBBC594DDB9F3 F4B32F46226BADA7
751E8FBC860EE5FB 14EA5627C0843D90 F723CA908E7AF2EE A129CA6149BE45E5
3F2ACC7F57C29BDB 699AE9F52CBE4794 4BC1B3F0968DD39C BB6DC91DA77961BD
BED65CF21AA2EE98 D0F2CBB02E3B67C7 93536795E3A33E88 A80C038CCD5CCEC8
B8AD50C6F649AF94 BCE192DE8A85B8EA 17D835B85BBB15F3 2F2E6163076BCFAD
DE4DAAACA71DC9A5 A6A2506687956571 AD87A3535C49EF28 32D892FAD841C342
7127512F72F27CCE A7F32346F95978E3 12E0B01ABB051238 15E034D40FA197AE
314DFFBE0815A3B4  27990F029623981 CADCD4E59EF40C4D 9ABFD8766A33735C
 E3EA96B5304A7D0 AD0C42D6FC585992 187306C89BC215A9 D4A60ABCF3792B95
F935451DE4F21DF2 A9538F0419755787 DB9ACDDFF56CA510 D06C98CD5C0975EB
E612A3CB9ECBA951 C766E62CFCADAF96 EE64435A9752FE72 A192D576B245165A
 A8787BF8ECB74B2 81B3E73D20B49B6F 7FA8220BA3B2ECEA 245731C13CA42499
B78DBFAF3A8D83BD EA1AD565322A1A0B 60E61C23A3795013 6606D7E446282B93
6CA4ECB15C5F91E1 9F626DA15C9625F3 E51B38608EF25F57 958A324CEB064572
>;

for @refvecs.kv -> $n, $vec {
    $s .= new(:key(0x000102030405060708090a0b0c0d0e0f));
    is $s.finalize(0..$n-1).Int.base(16), $vec,
        "Reference vector #$n matches"
}
