use v6.d;
use Test;

#
# Copyright © 2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;
use Net::BGP::Conversions;
use Net::BGP::Message;
use Net::BGP::Message::Update;

my $fh = open "t/data/replay.full.bgp", :r;

my $start = DateTime.now;
my $count = 0;

while ! $fh.eof {
    $fh.read(16).sink; # Read (and silently discard) header
    my $raw = $fh.read(nuint16($fh.read(2))-18); # Read appropriate length
    my $msg = Net::BGP::Message.from-raw($raw, :asn32);

    if $msg ~~ Net::BGP::Message::Update {
        $msg.nlri.sink;
        $msg.nlri6.sink;
        $msg.withdrawn.sink;
        $msg.withdrawn6.sink;
        $msg.community-list.sink;
        $msg.path.sink;
    }
    
    $count++;
    if $count %% 1_000 {
        say "# Read Message $count";
    }
}

my $done = DateTime.now;
say "MESSAGES: $count";
say "DURATION: " ~ ($done-$start).fmt("%.1f");
say "MSGS/SEC: " ~ ( $count / ($done-$start) ).fmt("%.1f");

$fh.close;

