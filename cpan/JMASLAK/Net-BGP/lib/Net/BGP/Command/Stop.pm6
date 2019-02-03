use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Command;

use StrictClass;
unit class Net::BGP::Command::Stop:ver<0.1.1>:auth<cpan:JMASLAK>
    is Net::BGP::Command
    does StrictClass;

method message-name(-->Str) { 'Stop' };

=begin pod

=head1 NAME

Net::BGP::Command::Stop - BGP Stop Server Command

=head1 SYNOPSIS

  use Net::BGP::Command::Stop;

  my $msg = Net::BGP::Command::Stop.new();

=head1 DESCRIPTION

A Stop command.

The Stop command is only sent from user code to the BGP server.  It will cause
the BGP server to shut down all the connections.

=head1 METHODS

=head2 message-name

Contains the string C<Stop>.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
