use v6.c;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Message;

my $msg = Buf[uint8].new(
    2,          # Update
    0,0,        # Withdrawn Routes (0)
    0,46,       # Path Attribute Length (46 bytes)
    64,1,1,2,   #   Origin
    80,2,0,20,  #   AS Path - 20 Bytes
    2,          #     Type 2 (AS SEQ)
    3,          #     3 ASNs
    0,0,255,221,#       ASN #1
    0,0,174,140,#       ASN #2
    0,0,33,82,  #       ASN #3
    1,          #     Type 1 (AS SEt)
    1,          #     1 ASN
    0,3,8,97,   #       ASN #1                           # 28
    64,3,4,     #   Attribute Code 3
    93,93,131,102, # Data for Attribute Code 3           # 35
    192,7,8,    #   Attribute Code 7                     # 38
    0,0,33,82,91,143,64,24, # Data for code 7
    21,5,39,176 # VALID!
);
my $bgp = Net::BGP::Message.from-raw( $msg, :asn32 );
ok defined($bgp), "BGP message is defined";
is $bgp.message-code, 2, 'Message type is correct';
is $bgp.message-name, 'UPDATE', 'Message code is correct';
is $bgp.nlri[0], '5.39.176.0/21', 'NLRI right';
is $bgp.path-attributes.elems, 4, 'right number of path elems';
is $bgp.nlri6.elems, 0, 'No NLRI6 Elements';
is $bgp.aggregator-asn, 8530, 'Aggregator ASN correct';
is $bgp.aggregator-ip, '91.143.64.24', "Aggregator IP correct";

done-testing;

