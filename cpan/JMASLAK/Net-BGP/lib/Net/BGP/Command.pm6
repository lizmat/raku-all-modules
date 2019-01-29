use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

unit class Net::BGP::Command:ver<0.1.0>:auth<cpan:JMASLAK>;

has Int $.connection-id;

method message-name(-->Str) { 'NOOP' };

=begin pod

=head1 NAME

Net::BGP::Command - BGP Server Noitfy Superclass

=head1 SYNOPSIS

  use Net::BGP::Command;

  my $msg = Net::BGP::Command.new( :message-name<NOOP> );

=head1 DESCRIPTION

Parent class for messages (commands) from user code to BGP server code.

=head1 ATTRIBUTES

=head2 connection-id

This contains the appropriate connection ID associated with the command.

=head1 METHODS

=head2 message-name

Contains a string that describes what message type the command represents.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
