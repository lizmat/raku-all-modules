use v6.c;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Message;

my $bgp = Net::BGP::Message.from-raw( read-message('open-message-capabilities.2'), :!asn32 );
ok defined($bgp), "BGP message is defined";
is $bgp.message-code, 1, 'Message type is correct';
is $bgp.message-name, 'OPEN', 'Message code is correct';
is $bgp.version, 4, 'BGP version is correct';
is $bgp.asn, :16('1020'), 'ASN is correct';
is $bgp.hold-time, 3, 'Hold time is correct';
is $bgp.identifier, :16('01020304'), 'BGP identifier is correct';
is $bgp.parameters.elems, 3, "Proper number of Parameters";

ok $bgp.parameters[0] ~~ Net::BGP::Parameter::Capabilities, "Parameter¹ is a Capabilitiy";
is $bgp.parameters[0].parameter-code, 2, "Parameter¹ has proper code";
is $bgp.parameters[0].parameter-name, "Capabilities", "Parameter¹ has proper name";

ok $bgp.parameters[1] ~~ Net::BGP::Parameter::Capabilities, "Parameter² is a Capabilitiy";
is $bgp.parameters[1].parameter-code, 2, "Parameter² has proper code";
is $bgp.parameters[1].parameter-name, "Capabilities", "Parameter² has proper name";

ok $bgp.parameters[2] ~~ Net::BGP::Parameter::Capabilities, "Parameter³ is a Capabilitiy";
is $bgp.parameters[2].parameter-code, 2, "Parameter³ has proper code";
is $bgp.parameters[2].parameter-name, "Capabilities", "Parameter³ has proper name";

my $caps = $bgp.parameters[0].capabilities;
is $caps.elems, 1, "Parameter¹ Proper number of capabilities";
ok $caps[0] ~~ Net::BGP::Capability::Route-Refresh, "Capability¹ is proper type";
is $caps[0].capability-code, 2,                     "Capability¹ has proper code";
is $caps[0].capability-name, "Route-Refresh",       "Capability¹ has proper name";

$caps = $bgp.parameters[1].capabilities;
is $caps.elems, 1, "Parameter² Proper number of capabilities";
ok $caps[0] ~~ Net::BGP::Capability::ASN32, "Capability² is proper type";
is $caps[0].capability-code, 65,            "Capability² has proper code";
is $caps[0].capability-name, "ASN32",       "Capability² has proper name";
is $caps[0].asn, :16('12345678'),           "Capability² has proper asn";

$caps = $bgp.parameters[2].capabilities;
is $caps.elems, 1, "Parameter³ Proper number of capabilities";
ok $caps[0] ~~ Net::BGP::Capability::MPBGP,   "Capability³ is proper type";
is $caps[0].capability-code, 1,               "Capability³ has proper code";
is $caps[0].capability-name, "MPBGP",         "Capability³ has proper name";
is $caps[0].afi,             "IP",            "Capability³ has proper afi";
is $caps[0].safi,            "unicast",       "Capability³ has proper safi";
is $caps[0].reserved,        0,               "Capability³ has proper reserved";

ok check-list($bgp.raw, read-message('open-message-capabilities.2')), 'Message value correct';;

done-testing;

sub read-message($filename) {
    buf8.new( slurp("t/bgp-messages/$filename.msg", :bin)[18..*] ); # Strip header
}

sub check-list($a, $b -->Bool) {
    if $a.elems != $b.elems { return False; }
    return [&&] $a.values Z== $b.values;
}

