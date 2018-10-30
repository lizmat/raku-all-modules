use v6;

use Test;
use Data::MessagePack;

plan 3;

is-deeply Data::MessagePack::unpack( Data::MessagePack::pack( { key => 'value' } ) ), { key => 'value' }, "hash packed correctly";

is-deeply Data::MessagePack::unpack( Data::MessagePack::pack( { a => Any, b => [ 1 ], c => { aa => 3, bb => [] } } ) ), { a => Any, b => [ 1 ], c => { aa => 3, bb => [] } }, "hash packed correctly";

my %hh;
for ^16 -> $i { %hh{$i} = $i };
is-deeply Data::MessagePack::unpack( Data::MessagePack::pack( %hh ) ), %hh, "hash packed correctly";
