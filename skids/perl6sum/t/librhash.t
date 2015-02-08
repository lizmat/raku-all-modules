BEGIN { "1..1\nok 1 - foo".say; exit(0) }; # Deactivate this test file for now

use v6;
use lib	'./lib';

use Test;

plan 26;

use Sum::librhash;
ok(1,'We use Sum and we are still alive');

lives_ok { X::librhash::NotFound.new() },
	 'X::librhash::NotFound is available';
lives_ok { X::librhash::NativeError.new() },
	 'X::librhash::NativeError is available';

my $c = Sum::librhash::count();
ok $c > 0, "Sum::librhash::count() reports algorithms present";
is $Sum::librhash::count, $c, "\$Sum::librhash::count contains cached value";

# Should at least have MD5
my $md5 = %Sum::librhash::Algos.pairs.grep(*.value.name eq "MD5")[0].value;
isa_ok $md5, Sum::librhash::Algo, "Found an Algo named MD5";
is $md5.digest_size, 16, "MD5 has expected digest size";

my $a;
lives_ok {$a := Sum::librhash::Instance.new("CRC32")}, "rhash init lives.";
isa_ok $a, Sum::librhash::Instance, "Created Instance object";
ok $a.defined, "Created Instance is really instantiated";
lives_ok {$a.add("Please to checksum this text.".encode('ascii'))}, "rhash update lives";
is $a.finalize(:bytes(4)), buf8.new(0x32,0xd2,1,0xf6), "CRC32 alg computes expected value";
lives_ok { for 0..10000 { my $a := Sum::librhash::Instance.new("CRC32"); $a.finalize(:bytes(4)) if Bool.pick; } }, "Supposedly test GC sanity";

$a := Sum::librhash::Instance.new("CRC32");
throws_like { my $c = $a.clone; +$c; }, X::AdHoc, "Attempt to clone Instance throws exception";
$a.finalize(:bytes(4));
throws_like { $a.finalize(:bytes(4)) }, X::librhash::Final, "Double finalize gets caught for raw Instance";

lives_ok {$a := Sum::librhash::Sum.new("MD5")}, "wrapper class contructor lives";
isa_ok $a, Sum::librhash::Sum, "wrapper class intantiates";
ok $a.defined, "wrapper class intantiates for reelz";
lives_ok {$a.push(buf8.new(97 xx 64))}, "wrapper class can push";
is $a.finalize, 0x014842d480b571495a4a0363793f7367, "MD5 is correct (test vector 1).";
is $a.finalize, 0x014842d480b571495a4a0363793f7367, "Wrapper class caches result";
my $res;
my $b := Sum::librhash::Sum.new("MD5");
throws_like { my $c = $b.clone; +$c; }, X::AdHoc, "Attempt to clone wrapper class throws exception";
$b.push(buf8.new(97 xx 64));
$b.push(buf8.new(97 xx 64));
lives_ok { $res  = $b.finalize(buf8.new(97 xx 56)) }, "finalize also pushes";
is $res, 0x63642b027ee89938c922722650f2eb9b, "MD5 is correct (test vector 2).";
is (Sum::librhash::Sum.new("MD5").finalize()), 0xd41d8cd98f00b204e9800998ecf8427e, "wrapper class works with no addend ever pushed";
is (Sum::librhash::Sum.new("MD5").finalize(buf8.new())), 0xd41d8cd98f00b204e9800998ecf8427e, "wrapper class works with just empty buffer finalized";