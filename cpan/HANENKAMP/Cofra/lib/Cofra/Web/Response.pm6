use v6;

unit role Cofra::Web::Response;

#use HTTP::Headers;

# method status(--> Int:D) { ... }
#
# method headers(--> HTTP::Headers:D) { ... }
# method header(--> HTTP::Header:D) { ... }
# method Content-Length(--> HTTP::Header:D) { ... }
# method Content-Type(--> HTTP::Header:D) { ... }
#
# method body(--> Any:D) { ... }

=begin pod

=head1 NAME

Cofra::Web::Response - the web response interface

=head1 DESCRIPTION

This defines the interface for response handling. It's the mold for responses.
It is not like that furry black stuff described by sinister documentaries, but
like one of those hollow shells that get filled with plastic or lead to make a
thing. This is the mold for describing how web responses in a request-response
protocol ought to behave (assuming something like HTTP/1.1 or HTTP/2).

=head1 CAVEATS

Ths actually does not declare much of that interface as of this writing. It's
mostly empty, but one day it will mandate that the methods defined elsewhere be
defined for anything wanting to act as a request object.

=end pod
