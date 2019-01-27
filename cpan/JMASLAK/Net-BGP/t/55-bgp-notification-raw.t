use v6.c;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Message;

subtest 'Open Notification Unsupported Version', {
    my $bgp = Net::BGP::Message.from-raw( read-message('notify-open-bad-version'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 3, 'Message type is correct';
    is $bgp.message-name, 'NOTIFY', 'Message code is correct';
    is $bgp.error-code, 2, 'Error code is correct';
    is $bgp.error-name, 'Open', 'Error name is correct';
    is $bgp.error-subcode, 1, 'Error subtype is correct';
    is $bgp.error-subname, 'Unsupported-Version', 'Error subtype is correct';
    ok $bgp ~~ Net::BGP::Message::Notify::Open::Unsupported-Version, 'Class is correct';
    is $bgp.max-supported-version, 4, 'Version is correct';
    ok check-list($bgp.raw, read-message('notify-open-bad-version')), 'Message value correct';

    done-testing;
};

subtest 'Open Notification Bad Peer AS', {
    my $bgp = Net::BGP::Message.from-raw( read-message('notify-open-bad-peer-asn'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 3, 'Message type is correct';
    is $bgp.message-name, 'NOTIFY', 'Message code is correct';
    is $bgp.error-code, 2, 'Error code is correct';
    is $bgp.error-name, 'Open', 'Error name is correct';
    is $bgp.error-subcode, 2, 'Error subtype is correct';
    is $bgp.error-subname, 'Bad-Peer-AS', 'Error subtype is correct';
    ok $bgp ~~ Net::BGP::Message::Notify::Open::Bad-Peer-AS, 'Class is correct';
    ok check-list($bgp.raw, read-message('notify-open-bad-peer-asn')), 'Message value correct';

    done-testing;
};

subtest 'Open Notification Unsupported Optional Parameter', {
    my $bgp = Net::BGP::Message.from-raw( read-message('notify-open-unsupported-optional-parameter'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.message-code, 3, 'Message type is correct';
    is $bgp.message-name, 'NOTIFY', 'Message code is correct';
    is $bgp.error-code, 2, 'Error code is correct';
    is $bgp.error-name, 'Open', 'Error name is correct';
    is $bgp.error-subcode, 4, 'Error subtype is correct';
    is $bgp.error-subname, 'Unsupported-Optional-Parameter', 'Error subtype is correct';
    ok $bgp ~~ Net::BGP::Message::Notify::Open::Unsupported-Optional-Parameter, 'Class is correct';
    ok check-list($bgp.raw, read-message('notify-open-unsupported-optional-parameter')), 'Message value correct';

    done-testing;
};

subtest 'Header Notification Connection not Syncronized', {
    my $bgp = Net::BGP::Message.from-raw( read-message('notify-header-connection-not-syncronized'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.raw.list, read-message('notify-header-connection-not-syncronized').list, "AAA";
    is $bgp.message-code, 3, 'Message type is correct';
    is $bgp.message-name, 'NOTIFY', 'Message code is correct';
    is $bgp.error-code, 1, 'Error code is correct';
    is $bgp.error-name, 'Header', 'Error name is correct';
    is $bgp.error-subcode, 1, 'Error subtype is correct';
    is $bgp.error-subname, 'Connection-Not-Syncronized', 'Error subtype is correct';
    ok $bgp ~~ Net::BGP::Message::Notify::Header::Connection-Not-Syncronized, 'Class is correct';
    ok check-list($bgp.raw, read-message('notify-header-connection-not-syncronized')), 'Message value correct';

    done-testing;
};

subtest 'Hold-Timer-Expired', {
    my $bgp = Net::BGP::Message.from-raw( read-message('notify-hold-timer-expired'), :!asn32 );
    ok defined($bgp), "BGP message is defined";
    is $bgp.raw.list, read-message('notify-hold-timer-expired').list, "raw matches message";
    is $bgp.message-code, 3, 'Message type is correct';
    is $bgp.message-name, 'NOTIFY', 'Message code is correct';
    is $bgp.error-code, 4, 'Error code is correct';
    is $bgp.error-name, 'Hold-Timer-Expired', 'Error name is correct';
    is $bgp.error-subcode, 0, 'Error subtype is correct';
    is $bgp.error-subname, '0', 'Error subtype is correct';
    ok $bgp ~~ Net::BGP::Message::Notify::Hold-Timer-Expired, 'Class is correct';
    ok check-list($bgp.raw, read-message('notify-hold-timer-expired')), 'Message value correct';
}

done-testing;

sub read-message($filename) {
    buf8.new( slurp("t/bgp-messages/$filename.msg", :bin)[18..*] ); # Strip header
}

sub check-list($a, $b -->Bool) {
    warn $a.elems if $a.elems != $b.elems;
    warn $b.elems if $a.elems != $b.elems;
    if $a.elems != $b.elems { return False; }
    return [&&] $a.values Z== $b.values;
}

