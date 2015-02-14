
use v6;
use lib	'./lib';

use Test;

my $abort = False;

if try { Sum::libmhash::count() } {
   plan 32;
}
else {
   plan 3;
   $abort = True;
}

use Sum::libmhash;
ok(1,'We use Sum and we are still alive');

lives_ok { X::libmhash::NotFound.new() },
	 'X::libmhash::NotFound is available';
lives_ok { X::libmhash::NativeError.new() },
	 'X::libmhash::NativeError is available';

if $abort {
   diag "No libmash detected, or other very basic problem.  Skipping tests.";
   exit;
}

my $c = Sum::libmhash::count();
ok $c > 0, "Sum::libmhash::count() reports algorithms present";
is $Sum::libmhash::count, $c, "\$Sum::libmhash::count contains cached value";

# Should at least have MD5
my $md5 = %Sum::libmhash::Algos.pairs.grep(*.value.name eq "MD5")[0].value;
isa_ok $md5, Sum::libmhash::Algo, "Found an Algo named MD5";
is $md5.block_size, 16, "MD5 has expected digest size";
is $md5.pblock_size, 64, "MD5 has expected P-Block size";

# We need to check Adler to ensure the endianness issue has been addressed
my $a;
lives_ok {$a := Sum::libmhash::Instance.new("ADLER32")}, "mhash init lives.";
isa_ok $a, Sum::libmhash::Instance, "Created Instance object";
ok $a.defined, "Created Instance is really instantiated";
lives_ok {$a.add("Please to checksum this text".encode('ascii'))}, "mhash update lives";
my $b;
lives_ok {$b := $a.clone;}, "mhash cp (clone) lives.";
isa_ok $b, Sum::libmhash::Instance, "Cloned Instance object";
ok $b.defined, "Cloned Instance is really instantiated";

is $b.finalize, buf8.new(0x96,0x25,0x0a,0x8e), "Adler32 clone computes expected value";
lives_ok {$a.add(buf8.new('.'.ord))}, "mhash update of original lives";
is $a.finalize, buf8.new(0xa0,0xe1,0x0a,0xbc), "Original Adler32 computes expected value";

lives_ok { for 0..10000 { my $a := Sum::libmhash::Instance.new("ADLER32"); $a.finalize if Bool.pick; } }, "Supposedly test GC sanity";

lives_ok {$a := Sum::libmhash::Sum.new("MD5")}, "wrapper class contructor lives";
isa_ok $a, Sum::libmhash::Sum, "wrapper class intantiates";
ok $a.defined, "wrapper class intantiates for reelz";
lives_ok {$a.push(buf8.new(97 xx 64))}, "wrapper class can push";
lives_ok {$b := $a.clone}, "wrapper class clone lives";
isa_ok $b, Sum::libmhash::Sum, "wrapper clone typecheck";
ok $b.defined, "wrapper clone definedness";
lives_ok {$b.push(buf8.new(97 xx 64))}, "wrapper clone can push";
is $a.finalize, 0x014842d480b571495a4a0363793f7367, "MD5 is correct (test vector 1).";
my $res;
lives_ok { $res  = $b.finalize(buf8.new(97 xx 56)) }, "finalize also pushes";
is $res, 0x63642b027ee89938c922722650f2eb9b, "MD5 is correct (test vector 2).";
is (Sum::libmhash::Sum.new("MD5").finalize()), 0xd41d8cd98f00b204e9800998ecf8427e, "wrapper class works with no addend ever pushed";
is (Sum::libmhash::Sum.new("MD5").finalize(buf8.new())), 0xd41d8cd98f00b204e9800998ecf8427e, "wrapper class works with just empty buffer finalized";