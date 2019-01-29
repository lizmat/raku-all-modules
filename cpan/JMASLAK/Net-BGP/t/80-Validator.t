use v6.c;
use Test;

#
# Copyright © 2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Message;
use Net::BGP::Validation;

subtest 'Good' => {

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
    my @errors = Net::BGP::Validation::errors($bgp);
    is @errors, (), "No warnings in message";
}

subtest 'AF_MIX' => {
    my $msg = read-message("update-mp-with-v4");
    my $bgp = Net::BGP::Message.from-raw( $msg, :!asn32 );
    my @errors = Net::BGP::Validation::errors($bgp);
    is @errors».key, «AFMIX AGGR_ASN_DOC AGGR_ID_BOGON», "Errors Found";

    done-testing;
}

subtest 'Aggregator ASN' => {

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
        0,0,0,0,91,143,64,24, # Data for code 7
        21,5,39,176 # VALID!
    );
    my $bgp = Net::BGP::Message.from-raw( $msg, :asn32 );
    my @errors = Net::BGP::Validation::errors($bgp);
    is @errors».key, «AGGR_ASN_RESERVED», "First message has AGGR_ASN_RESERVED";

    $msg = Buf[uint8].new(
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
        0,0,255,254,91,143,64,24, # Data for code 7
        21,5,39,176 # VALID!
    );
    $bgp = Net::BGP::Message.from-raw( $msg, :asn32 );
    @errors = Net::BGP::Validation::errors($bgp);
    is @errors».key, «AGGR_ASN_PRIVATE», "Second message has AGGR_ASN_PRIVATE";

    $msg = Buf[uint8].new(
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
        0,0,0x5B,0xA0,91,143,64,24, # Data for code 7
        21,5,39,176 # VALID!
    );
    $bgp = Net::BGP::Message.from-raw( $msg, :asn32 );
    @errors = Net::BGP::Validation::errors($bgp);
    is @errors».key, «AGGR_ASN_TRANS», "Third message has AGGR_ASN_TRANS";

    done-testing;
}

done-testing;


sub read-message($filename) {
    buf8.new( slurp("t/bgp-messages/$filename.msg", :bin)[18..*] ); # Strip header
}
