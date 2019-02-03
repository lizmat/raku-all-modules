use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

unit role Net::BGP::Connection-Role:ver<0.1.1>:auth<cpan:JMASLAK>;

use Net::BGP::Message;

my Int $last_id = 0;

has Int:D  $.id = $last_id++;
has Bool:D $.inbound     is required;
has Str:D  $.remote-ip   is required;
has Int:D  $.remote-port is required where ^65536;

method close(-->Nil) { … }
method send-bgp(Net::BGP::Message:D $msg -->Nil) { … }

=begin pod

=head1 NAME

Net::BGP::Connection-Role - BGP Server Connection Role

=head1 DESCRIPTION

Used internally to represent the interface to a C<Net::BGP::Connection>.

=head1 ATTRIBUTES

=head2 id

A unique ID number associated with this connection.

=head2 inbound

True if the connection is an inbound connection.

=head2 remote-ip

The IP of the remote end of the connection.

=head2 remote-port

The port of the remote end of the connection.

=head1 METHODS

=head2 close(-->Nil)

Close the connection.

=head2 send-bgp(Net::BGP::Message:D $msg -->Nil)

  $conn.send-bgp($msg)

Sends a BGP message to the remote peer.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
