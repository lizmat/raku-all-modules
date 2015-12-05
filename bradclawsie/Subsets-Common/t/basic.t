use v6;
use Test;
use Subsets::Common;

plan 29;

lives-ok { my PosInt $i = 1; }, "PosInt in range";
lives-ok { my NegInt $i = -1; }, "NegInt in range";
lives-ok { my ZeroInt $i = 0; }, "ZeroInt in range";
lives-ok { my UInt $i = 1; }, "UInt in range";
lives-ok { my Int32 $i = 2147483647; }, "Int32 in range";
lives-ok { my Int32 $i = -2147483648; }, "Int32 in range";
lives-ok { my UInt32 $i = 4294967295; }, "UInt32 in range";

lives-ok { my Pos $i = 1; }, "Pos in range";
lives-ok { my Neg $i = -1; }, "Neg in range";
lives-ok { my Zero $i = 0; }, "Zero in range";
lives-ok { my UInt $i = 1; }, "UNumeric in range";

lives-ok { my NonEmptyStr $s = 'hello'; }, "NonEmptyStr in range";
lives-ok { my EmptyStr $s = ''; }, "EmptyStr in range";

dies-ok { my PosInt $i = -1; }, "PosInt caught out of range";
dies-ok { my NegInt $i = 1; }, "NegInt caught out of range";
dies-ok { my ZeroInt $i = 1; }, "ZeroInt caught out of range";
dies-ok { my ZeroInt $i = -1; }, "ZeroInt caught out of range";
dies-ok { my UInt $i = -1; }, "UInt caught out of range";
dies-ok { my Int32 $i = 2147483648; }, "Int32 caught out of range";
dies-ok { my Int32 $i = -2147483649; }, "Int32 caught out of range";
dies-ok { my UInt32 $i = 4294967296; }, "UInt32 caught out of range";

dies-ok { my Pos $i = -1; }, "Pos caught out of range";
dies-ok { my Neg $i = 1; }, "Neg caught out of range";
dies-ok { my Zero $i = 1; }, "Zero caught out of range";
dies-ok { my Zero $i = -1; }, "Zero caught out of range";
dies-ok { my UInt $i = -1; }, "UNumeric caught out of range";

dies-ok { my NonEmptyStr $s = ''; }, "NonEmptyStr caught out of range";
dies-ok { my EmptyStr $s = 'hello'; }, "EmptyStr caught out of range";
dies-ok { my EmptyStr $s = ' '; }, "EmptyStr caught out of range";

done-testing;
