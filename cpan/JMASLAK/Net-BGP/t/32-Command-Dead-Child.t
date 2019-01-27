use v6.c;
use Test;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP;

my $msg = Net::BGP::Command::Dead-Child.new(
    :connection-id(1),
);
ok $msg, "Created Net::BGP::Command::Dead-Child Class";
is $msg.message-name, 'Dead-Child', 'Proper Dead-Child command';
is $msg.connection-id, 1, 'Payload is correct';

done-testing;

