use v6.c;
use Test;

#
# Copyright © 2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Message;
use Net::BGP::Validation;

subtest 'Unexpected AS4 Path' => {

    my $msg = Buf[uint8].new(
        2,          # Update
        0,0,        # Withdrawn Routes (0)
        0,57,       # Path Attribute Length (57 bytes)
        64,1,1,2,   #   Origin
        80,2,0,14,  #   AS Path - 14 Bytes
        2,          #     Type 2 (AS SEQ)
        3,          #     3 ASNs
        0,0,255,221,#       ASN #1
        0,0,174,140,#       ASN #2
        0,0,33,82,  #       ASN #3
        64,3,4,     #   Attribute Code 3
        93,93,131,102, # Data for Attribute Code 3           # 35
        192,7,8,    #   Attribute Code 7                     # 38
        0,0,33,82,91,143,64,24, # Data for code 7
        192,17,14,  #   AS4 Path - 14 Bytes
        2,          #     Type 2 (AS SEQ)
        3,          #     3 ASNs
        0,0,255,221,#       ASN #1
        0,0,174,140,#       ASN #2
        0,0,33,82,  #       ASN #3
        21,5,39,176 # VALID!
    );
    my $bgp = Net::BGP::Message.from-raw( $msg, :asn32 );
    my @errors = Net::BGP::Validation::errors(
        :message($bgp),
        :my-asn(65000),
        :peer-asn(65501)
    );
    is @errors».key, «AS4_PEER_SENT_AS4_PATH», "Errors Found";

    done-testing;
}

subtest 'Doc ASN' => {

    my $msg = Buf[uint8].new(
        2,          # Update
        0,0,        # Withdrawn Routes (0)
        0,40,       # Path Attribute Length (57 bytes)
        64,1,1,2,   #   Origin
        80,2,0,14,  #   AS Path - 14 Bytes
        2,          #     Type 2 (AS SEQ)
        3,          #     3 ASNs
        0,1,0,0,    #       ASN #1
        0,0,0,1,    #       ASN #2
        0,0,33,82,  #       ASN #3
        64,3,4,     #   Attribute Code 3
        93,93,131,102, # Data for Attribute Code 3
        192,7,8,    #   Attribute Code 7
        0,0,33,82,91,143,64,24, # Data for code 7
        21,5,39,176 # VALID!
    );
    my $bgp = Net::BGP::Message.from-raw( $msg, :asn32 );
    my @errors = Net::BGP::Validation::errors(
        :message($bgp),
        :my-asn(65000),
        :peer-asn(65501)
    );
    is @errors».key, «AS_PATH_DOC», "Errors Found";

    done-testing;
}

subtest 'PRIVATE ASN' => {

    my $msg = Buf[uint8].new(
        2,          # Update
        0,0,        # Withdrawn Routes (0)
        0,40,       # Path Attribute Length (57 bytes)
        64,1,1,2,   #   Origin
        80,2,0,14,  #   AS Path - 14 Bytes
        2,          #     Type 2 (AS SEQ)
        3,          #     3 ASNs
        0,0,255,221,#       ASN #1
        0,0,255,254,#       ASN #2
        0,0,33,82,  #       ASN #3
        64,3,4,     #   Attribute Code 3
        93,93,131,102, # Data for Attribute Code 3
        192,7,8,    #   Attribute Code 7
        0,0,33,82,91,143,64,24, # Data for code 7
        21,5,39,176 # VALID!
    );
    my $bgp = Net::BGP::Message.from-raw( $msg, :asn32 );
    my @errors = Net::BGP::Validation::errors(
        :message($bgp),
        :my-asn(65000),
        :peer-asn(65501)
    );
    is @errors».key, «AS_PATH_PRIVATE», "Errors Found";

    done-testing;
}

subtest 'Reserved ASN' => {

    my $msg = Buf[uint8].new(
        2,          # Update
        0,0,        # Withdrawn Routes (0)
        0,40,       # Path Attribute Length (57 bytes)
        64,1,1,2,   #   Origin
        80,2,0,14,  #   AS Path - 14 Bytes
        2,          #     Type 2 (AS SEQ)
        3,          #     3 ASNs
        0,0,255,221,#       ASN #1
        0,0,0,0,    #       ASN #2
        0,0,33,82,  #       ASN #3
        64,3,4,     #   Attribute Code 3
        93,93,131,102, # Data for Attribute Code 3
        192,7,8,    #   Attribute Code 7
        0,0,33,82,91,143,64,24, # Data for code 7
        21,5,39,176 # VALID!
    );
    my $bgp = Net::BGP::Message.from-raw( $msg, :asn32 );
    my @errors = Net::BGP::Validation::errors(
        :message($bgp),
        :my-asn(65000),
        :peer-asn(65501)
    );
    is @errors».key, «AS_PATH_RESERVED», "Errors Found";

    done-testing;
}

subtest 'Trans ASN' => {

    my $msg = Buf[uint8].new(
        2,          # Update
        0,0,        # Withdrawn Routes (0)
        0,40,       # Path Attribute Length (57 bytes)
        64,1,1,2,   #   Origin
        80,2,0,14,  #   AS Path - 14 Bytes
        2,          #     Type 2 (AS SEQ)
        3,          #     3 ASNs
        0,0,255,221,#       ASN #1
        0,0,0x5b,0xa0,#     ASN #2
        0,0,33,82,  #       ASN #3
        64,3,4,     #   Attribute Code 3
        93,93,131,102, # Data for Attribute Code 3
        192,7,8,    #   Attribute Code 7
        0,0,33,82,91,143,64,24, # Data for code 7
        21,5,39,176 # VALID!
    );
    my $bgp = Net::BGP::Message.from-raw( $msg, :asn32 );
    my @errors = Net::BGP::Validation::errors(
        :message($bgp),
        :my-asn(65000),
        :peer-asn(65501)
    );
    is @errors».key, «AS_PATH_TRANS», "Errors Found";

    done-testing;
}

done-testing;

