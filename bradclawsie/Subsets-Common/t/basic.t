use v6;
use Test;
use Subsets::Common;

subtest {
    lives-ok { my PosInt $i = 1; }, "PosInt in range";
    lives-ok { my NegInt $i = -1; }, "NegInt in range";
    lives-ok { my ZeroInt $i = 0; }, "ZeroInt in range";

    lives-ok { my Int8 $i = 127; }, "Int8 in range";
    lives-ok { my Int8 $i = -128; }, "Int8 in range";
    lives-ok { my UInt8 $i = 255; }, "UInt32 in range"; 
    lives-ok { my Int16 $i = 32767; }, "Int16 in range";
    lives-ok { my Int16 $i = -32768; }, "Int16 in range";
    lives-ok { my UInt16 $i = 65535; }, "UInt16 in range"; 
    lives-ok { my Int32 $i = 2147483647; }, "Int32 in range";
    lives-ok { my Int32 $i = -2147483648; }, "Int32 in range";
    lives-ok { my UInt32 $i = 4294967295; }, "UInt32 in range";
    lives-ok { my Int64 $i = 9223372036854775807; }, "Int64 in range";
    lives-ok { my Int64 $i = -9223372036854775808; }, "Int64 in range";
    lives-ok { my UInt64 $i = 18446744073709551615; }, "UInt64 in range";
    
    lives-ok { my Pos $i = 1; }, "Pos in range";
    lives-ok { my Neg $i = -1; }, "Neg in range";
    lives-ok { my Zero $i = 0; }, "Zero in range";
    lives-ok { my UNumeric $i = 1; }, "UNumeric in range";

    dies-ok { my PosInt $i = -1; }, "PosInt caught out of range";
    dies-ok { my NegInt $i = 1; }, "NegInt caught out of range";
    dies-ok { my ZeroInt $i = 1; }, "ZeroInt caught out of range";
    dies-ok { my ZeroInt $i = -1; }, "ZeroInt caught out of range";

    dies-ok { my Int8 $i = 128; }, "Int8 caught out of range";
    dies-ok { my Int8 $i = -129; }, "Int8 caught out of range";
    dies-ok { my UInt8 $i = 256; }, "UInt8 caught out of range";
    dies-ok { my Int16 $i = 32768; }, "Int16 caught out of range";
    dies-ok { my Int16 $i = -32769; }, "Int16 caught out of range";
    dies-ok { my UInt16 $i = 65536; }, "UInt16 caught out of range";
    dies-ok { my Int32 $i = 2147483648; }, "Int32 caught out of range";
    dies-ok { my Int32 $i = -2147483649; }, "Int32 caught out of range";
    dies-ok { my UInt32 $i = 4294967296; }, "UInt32 caught out of range";
    dies-ok { my Int64 $i = 9223372036854775808; }, "Int64 caught out of range";
    dies-ok { my Int64 $i = -9223372036854775809; }, "Int64 caught out of range";
    dies-ok { my UInt64 $i = 18446744073709551616; }, "UInt64 caught out of range";
    
    dies-ok { my Pos $i = -1; }, "Pos caught out of range";
    dies-ok { my Neg $i = 1; }, "Neg caught out of range";
    dies-ok { my Zero $i = 1; }, "Zero caught out of range";
    dies-ok { my Zero $i = -1; }, "Zero caught out of range";
    dies-ok { my UNumeric $i = -1; }, "UNumeric caught out of range";
}, 'integer types';

subtest {
    lives-ok { my Odd $n = 137 }, "Odd lives with 137";
    dies-ok  { my Odd $n =  42 }, "Odd dies with 42";
    lives-ok { my Even $n = 42 }, "Even lives with 42";
    dies-ok  { my Even $n = 37 }, "Even dies with 37";
}, 'Odd and Even types';

subtest {
    lives-ok { my NonEmptyStr $s = 'hello'; }, "NonEmptyStr in range";
    lives-ok { my EmptyStr $s = ''; }, "EmptyStr in range";

    dies-ok { my NonEmptyStr $s = ''; }, "NonEmptyStr caught out of range";
    dies-ok { my EmptyStr $s = 'hello'; }, "EmptyStr caught out of range";
    dies-ok { my EmptyStr $s = ' '; }, "EmptyStr caught out of range";
}, 'NonEmptyStr and EmptyStr';

subtest {
    lives-ok { my ValueStr $s = 'Camelia' }, 'ValueStr lives with characters';
    dies-ok  { my ValueStr $s = '' }, 'ValueStr dies with empty string';
    dies-ok  { my ValueStr $s = "\n" }, 'ValueStr dies with newline';
}, 'ValueStr';

subtest {
    for 1 .. 12 -> $hour {
        lives-ok { my Time::Hour12 $h = $hour }, "Time::Hour12 lives for $hour";
    }
    dies-ok { my Time::Hour12 $h = 13 }, "Time::Hour12 dies for 13";
    dies-ok { my Time::Hour12 $h =  0 }, "Time::Hour12 dies for  0";
    dies-ok { my Time::Hour12 $h = -3 }, "Time::Hour12 dies for -3";
    
    for 0 .. 23 -> $hour {
        lives-ok { my Time::Hour24 $h = $hour }, "Time::Hour24 lives for $hour";
    }
    dies-ok { my Time::Hour24 $h = 24 }, "Time::Hour24 dies for 24";
    dies-ok { my Time::Hour24 $h = -3 }, "Time::Hour24 dies for -3";
    
    for 0 .. 59 -> $n {
        lives-ok { my Time::Minute $m = $n }, "Time::Minute lives for $n";
        lives-ok { my Time::Second $s = $n }, "Time::Second lives for $n";
    }
    dies-ok { my Time::Minute $m = 137 }, "Time::Minute dies for 137";
    dies-ok { my Time::Minute $h =  -3 }, "Time::Hour24 dies for -3";
}, 'time types';

done-testing;
