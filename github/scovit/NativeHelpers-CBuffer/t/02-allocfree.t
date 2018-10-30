use v6.c;
use Test;
use NativeHelpers::CBuffer;

my CBuffer $a = CBuffer.new(10);
$a.free;

pass "NativeHelpers::CBuffer creates and destroy buffers correctly";

done-testing;
