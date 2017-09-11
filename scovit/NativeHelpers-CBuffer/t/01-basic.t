use v6.c;
use Test;
use NativeHelpers::CBuffer;

my CBuffer $a = CBuffer.new(10);

pass "NativeHelpers::CBuffer loaded correctly";

done-testing;
