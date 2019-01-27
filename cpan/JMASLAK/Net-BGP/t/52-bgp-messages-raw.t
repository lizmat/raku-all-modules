use v6.d;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Message;

subtest 'Generic', {
    my $bgp = Net::BGP::Message.from-raw( read-message('noop-message'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 0, 'Message type is correct';
    is $bgp.message-name, '0', 'Message code is correct';
    ok check-list($bgp.raw, read-message('noop-message')), 'Message value correct';;

    done-testing;
};

subtest 'Open Message', {
    my $bgp = Net::BGP::Message.from-raw( read-message('open-message'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 1, 'Message type is correct';
    is $bgp.message-name, 'OPEN', 'Message code is correct';
    is $bgp.version, 4, 'BGP version is correct';
    is $bgp.asn, :16('1020'), 'ASN is correct';
    is $bgp.hold-time, 3, 'Hold time is correct';
    is $bgp.identifier, :16('01020304'), 'BGP identifier is correct';
    ok check-list($bgp.raw, read-message('open-message')), 'Message value correct';;

    done-testing;
};

subtest 'Open Message w/ Capabilities', {
    my $bgp = Net::BGP::Message.from-raw( read-message('open-message-capabilities'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 1, 'Message type is correct';
    is $bgp.message-name, 'OPEN', 'Message code is correct';
    is $bgp.version, 4, 'BGP version is correct';
    is $bgp.asn, :16('1020'), 'ASN is correct';
    is $bgp.hold-time, 3, 'Hold time is correct';
    is $bgp.identifier, :16('01020304'), 'BGP identifier is correct';
    is $bgp.ipv4-support, True, 'IPv4 Support';
    is $bgp.ipv6-support, True, 'IPv6 Support';
    is $bgp.parameters.elems, 1, "Proper number of Parameters";
    ok $bgp.parameters[0] ~~ Net::BGP::Parameter::Capabilities, "Parameter is a Capabilitiy";
    is $bgp.parameters[0].parameter-code, 2, "Parameter has proper code";
    is $bgp.parameters[0].parameter-name, "Capabilities", "Parameter has proper name";

    my $caps = $bgp.parameters[0].capabilities;
    is $caps.elems, 4, "Proper number of capabilities";

    ok $caps[0] ~~ Net::BGP::Capability::Route-Refresh, "Capability¹ is proper type";
    is $caps[0].capability-code, 2,                     "Capability¹ has proper code";
    is $caps[0].capability-name, "Route-Refresh",       "Capability¹ has proper name";

    ok $caps[1] ~~ Net::BGP::Capability::ASN32, "Capability² is proper type";
    is $caps[1].capability-code, 65,            "Capability² has proper code";
    is $caps[1].capability-name, "ASN32",       "Capability² has proper name";
    is $caps[1].asn, :16('12345678'),           "Capability² has proper asn";

    ok $caps[2] ~~ Net::BGP::Capability::MPBGP,   "Capability³ is proper type";
    is $caps[2].capability-code, 1,               "Capability³ has proper code";
    is $caps[2].capability-name, "MPBGP",         "Capability³ has proper name";
    is $caps[2].afi,             "IP",            "Capability³ has proper afi";
    is $caps[2].safi,            "unicast",       "Capability³ has proper safi";
    is $caps[2].reserved,        0,               "Capability³ has proper reserved";

    ok $caps[3] ~~ Net::BGP::Capability::MPBGP,   "Capability⁴ is proper type";
    is $caps[3].capability-code, 1,               "Capability⁴ has proper code";
    is $caps[3].capability-name, "MPBGP",         "Capability⁴ has proper name";
    is $caps[3].afi,             "IPv6",          "Capability⁴ has proper afi";
    is $caps[3].safi,            "unicast",       "Capability⁴ has proper safi";
    is $caps[3].reserved,        0,               "Capability⁴ has proper reserved";

    ok check-list($bgp.raw, read-message('open-message-capabilities')), 'Message value correct';;

    done-testing;
};

subtest 'Keep-Alive Message', {
    my $bgp = Net::BGP::Message.from-raw( read-message('keep-alive'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 4, 'Message type is correct';
    is $bgp.message-name, 'KEEP-ALIVE', 'Message code is correct';
    ok check-list($bgp.raw, read-message('keep-alive')), 'Message value correct';;

    done-testing;
};

subtest 'Update Message (ASN16)', {
    my $bgp = Net::BGP::Message.from-raw( read-message('update-asn16'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    ok $bgp ~~ Net::BGP::Message::Update, "BGP message is proper type";
    is $bgp.message-code, 2, 'Message type is correct';
    is $bgp.message-name, 'UPDATE', 'Message code is correct';

    is $bgp.withdrawn.elems, 3, "Proper number of withdrawn prefixes";
    is $bgp.withdrawn[0], '0.0.0.0/0',        "Withdrawn 1 correct";
    is $bgp.withdrawn[1], '192.168.150.0/24', "Withdrawn 2 correct";
    is $bgp.withdrawn[2], '192.168.150.1/32', "Withdrawn 3 correct";

    is $bgp.path-attributes.elems, 10, "Proper number of path elements";
    ok $bgp.path-attributes[0] ~~ Net::BGP::Path-Attribute::Origin,
        "Path Attribute 1 Proper Type";
    is $bgp.path-attributes[0].origin, '?', "Path Attribute 1 Proper Value";
    is $bgp.origin, '?', "Origin is valid";

    ok $bgp.path-attributes[1] ~~ Net::BGP::Path-Attribute::AS-Path,
        "Path Attribute 2 Proper Type";
    is $bgp.path-attributes[1].as-path, "{0x0102} {0x0304}", "Path Attribute 2 Proper Value";
    is $bgp.as-path, "{0x0102} {0x0304}", "as-path is valid";
    is $bgp.path, "{0x0102} {0x0304} ?", "path is valid";

    ok $bgp.path-attributes[2] ~~ Net::BGP::Path-Attribute::Next-Hop,
        "Path Attribute 3 Proper Type";
    is $bgp.path-attributes[2].ip, "10.0.0.1", "Path Attribute 3 Proper Value";
    is $bgp.next-hop, "10.0.0.1", "next-hop is valid";

    ok $bgp.path-attributes[3] ~~ Net::BGP::Path-Attribute::MED,
        "Path Attribute 4 Proper Type";
    is $bgp.path-attributes[3].med, 5000, "Path Attribute 4 Proper Value";

    ok $bgp.path-attributes[4] ~~ Net::BGP::Path-Attribute::Local-Pref,
        "Path Attribute 5 Proper Type";
    is $bgp.path-attributes[4].local-pref, 100, "Path Attribute 5 Proper Value";

    ok $bgp.path-attributes[5] ~~ Net::BGP::Path-Attribute::Atomic-Aggregate,
        "Path Attribute 6 Proper Type";
    is $bgp.atomic-aggregate, True, "Atomic Attribute is present";

    ok $bgp.path-attributes[6] ~~ Net::BGP::Path-Attribute::Aggregator,
        "Path Attribute 7 Proper Type";
    is $bgp.path-attributes[6].asn, 258, 'Aggregator ASN correct';
    is $bgp.path-attributes[6].ip, '192.0.2.6', "Aggregator IP correct";

    ok $bgp.path-attributes[7] ~~ Net::BGP::Path-Attribute::Community,
        "Path Attribute 8 Proper Type";
    is $bgp.path-attributes[7].community-list.join(" "), "2571:258", "Path Attribute 7 Proper Value";
    is $bgp.community-list.join(" "), "2571:258", "Communities are proper";

    ok $bgp.path-attributes[8] ~~ Net::BGP::Path-Attribute::Originator-ID,
        "Path Attribute 9 Proper Type";
    is $bgp.path-attributes[8].originator-id, "10.0.0.2", "Path Attribute 9 Proper Value";

    ok $bgp.path-attributes[9] ~~ Net::BGP::Path-Attribute::Cluster-List,
        "Path Attribute 10 Proper Type";
    is $bgp.path-attributes[9].cluster-list, "10.0.0.10 10.0.0.11",
        "Path Attribute 10 Proper Value";

    is $bgp.nlri.elems, 3, "Proper number of NLRI prefixes";
    is $bgp.nlri[0], '10.0.0.0/8',       "NLRI 1 correct";
    is $bgp.nlri[1], '192.168.151.0/24', "NLRI 1 correct";
    is $bgp.nlri[2], '192.168.151.1/32', "NLRI 1 correct";

    ok check-list($bgp.raw, read-message('update-asn16')), 'Message value correct';;

    done-testing;
};

subtest 'Update Message (MP-BGP)', {
    my $bgp = Net::BGP::Message.from-raw( read-message('update-mp'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    ok $bgp ~~ Net::BGP::Message::Update, "BGP message is proper type";
    is $bgp.message-code, 2, 'Message type is correct';
    is $bgp.message-name, 'UPDATE', 'Message code is correct';

    is $bgp.withdrawn.elems, 0, "Proper number of withdrawn prefixes";
    is $bgp.path-attributes.elems, 4, "Proper number of path elements";
    ok $bgp.path-attributes[0] ~~ Net::BGP::Path-Attribute::Origin,
        "Path Attribute 1 Proper Type";
    is $bgp.path-attributes[0].origin, '?', "Path Attribute 1 Proper Value";

    ok $bgp.path-attributes[1] ~~ Net::BGP::Path-Attribute::AS-Path,
        "Path Attribute 2 Proper Type";
    is $bgp.path-attributes[1].as-path, "{0x0102} {0x0304}", "Path Attribute 2 Proper Value";
    is $bgp.path-attributes[1].path-length, 2, "AS Path has proper length";

    ok $bgp.path-attributes[2] ~~ Net::BGP::Path-Attribute::MP-NLRI,
        "Path Attribute 3 Proper Type";
    is $bgp.path-attributes[2].afi, "IPv6", "Path Attribute 3A Proper Value";
    is $bgp.path-attributes[2].safi, "unicast", "Path Attribute 3B Proper Value";
    is $bgp.path-attributes[2].next-hop-global, "2001:db8::1", "Path Attribute 3C Proper Value";
    is $bgp.path-attributes[2].next-hop-local.defined, False, "Path Attribute 3D Proper Value";
    is $bgp.path-attributes[2].nlri.elems, 1, "Path Attribute 3E Proper Value";
    is $bgp.path-attributes[2].nlri[0], "2001:db8::/32", "Path Attribute 3F Proper Value";

    ok $bgp.path-attributes[3] ~~ Net::BGP::Path-Attribute::MP-Unreachable,
        "Path Attribute 4 Proper Type";
    is $bgp.path-attributes[3].afi, "IPv6", "Path Attribute 4A Proper Value";
    is $bgp.path-attributes[3].safi, "unicast", "Path Attribute 4B Proper Value";
    is $bgp.path-attributes[3].withdrawn.elems, 1, "Path Attribute 4E Proper Value";
    is $bgp.path-attributes[3].withdrawn[0], "2001:db8::/33", "Path Attribute 4F Proper Value";

    is $bgp.nlri.elems, 0, "Proper number of NLRI prefixes";

    ok check-list($bgp.raw, read-message('update-mp')), 'Message value correct';;

    done-testing;
};

done-testing;

sub read-message($filename) {
    buf8.new( slurp("t/bgp-messages/$filename.msg", :bin)[18..*] ); # Strip header
}

sub check-list($a, $b -->Bool) {
    if $a.elems != $b.elems { return False; }
    return [&&] $a.values Z== $b.values;
}

