use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Event;

unit class Net::BGP::Error:ver<0.1.1>:auth<cpan:JMASLAK>
    is Net::BGP::Event
    is Exception;

method message-name(-->Str) { 'NOOP'  };
method is-error(-->Bool)    { True    };
method message(-->Str)      { 'No-Op' };

=begin pod

=head1 NAME

Net::BGP::Error - BGP Server Error Superclass

=head1 SYNOPSIS

  use Net::BGP::Error;

  my $msg = Net::BGP::Error.new( :message-name<NOOP> );

=head1 DESCRIPTION

Parent class for messages (errors) used for communication from the BGP
server code to the user code.

=head1 METHODS

=head2 message-name

Contains a string that describes what message type the error represents.

=head2 is-error

Returns true or false based on whether this error represents an error.
It defaults to True in the parent class.

=head2 message

Returns a human-readable error message.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
