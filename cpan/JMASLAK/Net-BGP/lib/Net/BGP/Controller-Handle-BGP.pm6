use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

unit role Net::BGP::Controller-Handle-BGP:ver<0.0.8>:auth<cpan:JMASLAK>;

use Net::BGP::Connection-Role;
use Net::BGP::Message;
use Net::BGP::Message::Open;

# Receive Messages
multi method receive-bgp(
    Net::BGP::Connection-Role:D $connection,
    Net::BGP::Message:D $msg,
    Str:D $peer,
) { … }

# Handle errors
multi method handle-error(
    Net::BGP::Connection-Role:D $connection,
    Net::BGP::Error:D $e
    -->Nil
) { … };

# Deal with closed connections
method connection-closed(Net::BGP::Connection-Role:D $connection -->Nil) { … }

# Update last sent time
method update-last-sent(Net::BGP::Connection-Role:D $connection -->Nil) { … }

