use v6.d;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::AS-List;

my $buf = buf8.new( 1, 0 );
my $aslist = Net::BGP::AS-List.new( :raw($buf), :!asn32 );
is $aslist.ordered,    False,  "(0) ordered";
is $aslist.asn-size,   2,      "(0) asn-size";
is $aslist.asn-count,  0,      "(0) asn-count";
is $aslist.asns.elems, 0,      "(0) elems";

$buf = buf8.new( 1, 2, 9, 8, 7, 6 );
$aslist = Net::BGP::AS-List.new( :raw($buf), :!asn32 );
is $aslist.ordered,    False,  "(1) ordered";
is $aslist.asn-size,   2,      "(1) asn-size";
is $aslist.asn-count,  2,      "(1) asn-count";
is $aslist.asns.elems, 2,      "(1) elems";
is $aslist.asns[0],    0x0908, "(1) First ASN";
is $aslist.asns[1],    0x0706, "(1) Second ASN";

$buf = buf8.new( 2, 2, 9, 8, 7, 6, 5, 4, 3, 2 );
$aslist = Net::BGP::AS-List.new( :raw($buf), :asn32 );
is $aslist.ordered,    True,       "(2) ordered";
is $aslist.asn-size,   4,          "(2) asn-size";
is $aslist.asn-count,  2,          "(2) asn-count";
is $aslist.asns.elems, 2,          "(2) elems";
is $aslist.asns[0],    0x09080706, "(2) First ASN";
is $aslist.asns[1],    0x05040302, "(2) Second ASN";

$buf = buf8.new( 2, 1, 2, 3, 2, 3, 1, 2, 9, 8, 7, 6, 5, 4, 3, 2 );
my @aslists = Net::BGP::AS-List.as-lists( $buf, True );
is @aslists.elems,  2, "Proper number of AS lists";
is @aslists[0].Str, "{0x02030203}", "First AS Sequence is correct";
is @aslists[1].Str, "\{{0x09080706},{0x05040302}\}", "Second AS Sequence is correct";

@aslists = Net::BGP::AS-List.from-str('1 2', True);
is @aslists.elems,  1,     "(A) Proper number of AS lists";
is @aslists[0].Str, "1 2", "(A) First AS Sequence is correct";

@aslists = Net::BGP::AS-List.from-str('{1,2,3} 456 789 {101} 55', True);
is @aslists.elems,  4,                          "(B) Proper number of AS lists";
is @aslists[0].Str, '{1,2,3}', "(B) First AS Sequence is correct";
is @aslists[0].Str(:elems(1)), '{1}', "(B) First AS Sequence is correct (elems)";
is @aslists[0].ordered, False, "(B) First AS Sequence Ordering";
is @aslists[0].path-length, 1, "(B) First AS Sequence path length is correct";
is @aslists[1].Str, "456 789", "(B) Second AS Sequence is correct";
is @aslists[1].Str(:elems(1)), '456', "(B) Second AS Sequence is correct (elems 1)";
is @aslists[1].Str(:elems(2)), '456 789', "(B) Second AS Sequence is correct (elems 2)";
is @aslists[1].ordered, True,  "(B) Second AS Sequence Ordering";
is @aslists[1].path-length, 2, "(B) Second AS Sequence path length is correct";
is @aslists[2].Str, '{101}',   "(B) Third AS Sequence is correct";
is @aslists[2].ordered, False, "(B) Third AS Sequence Ordering";
is @aslists[2].path-length, 1, "(B) Third AS Sequence path length is correct";
is @aslists[3].Str, "55",      "(B) Forth AS Sequence is correct";
is @aslists[3].Str(:elems(1)), '55', "(B) Forth AS Sequence is correct (elems 1)";
is @aslists[3].ordered, True,  "(B) Forth AS Sequence Ordering";
is @aslists[3].path-length, 1, "(B) Forth AS Sequence path length is correct";

@aslists = Net::BGP::AS-List.from-str('', True);
is @aslists.elems,  0,     "(C) Proper number of AS lists";


done-testing;

