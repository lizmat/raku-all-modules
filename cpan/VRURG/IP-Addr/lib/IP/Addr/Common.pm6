#! /usr/bin/env false

=begin pod

=NAME    IP::Addr::Const

=head1 DESCRIPTION

This module contains common definitions for other modules of IP::Addr family.

=head2 Constants And Enums

=head3 enum SCOPE

Defines scopes of reserved IP blocks.

=begin table
Scope | Version
===============
undetermined    | 4,6
documentation   | 4,6
host            | 4,6
private         | 4,6
public          | 4,6
software        | 4,6
subnet          | 4,6
internet        | 6
link            | 6
routing         | 6
=end table

=head3 enum IP-FORM

Forms of IP address objects:

=item unknown
=item ip
=item cidr
=item range

=head2 Exceptions

=head3 X::IPAddr::TypeCheck

Raised when operation is performed on two objects of incompatible versions.

=head3 X::IPAddr::BadMappedV6

Raised when IPv6 is in IPv4 mapped format but incorrectly formed.

=end pod

use v6.c;

unit module IP::Addr::Const;

# routing and link are IPv6 specific
# internet, documentation, software, host, private valid for both v4 and v6
# public is a custom class for anything not been reserved
enum SCOPE is export «:undetermined(-1) :public(0) software private host subnet documentation internet routing link»;

enum IP-FORM is export «:unknown(0) ip cidr range»;

role IPv4-Basic is export {
    token ipv4 {
        <octet> ** 4 % '.'
    }
    
    token octet {
        \d ** 1..3 <?{ $/.Int < 256  }>
    }
}

class X::IPAddr::TypeCheck is Exception is export {
    has @ip-list;
    method message { "IP objects are of incompatible versions" }
}

class X::IPAddr::BadMappedV6 is Exception is export {
    method message { "Bad IPv4-mapped IPv6 address" }
}

=begin pod

=head1 See also

IP::Addr

=AUTHOR Vadim Belman <vrurg@cpan.org>

=end pod

# vim: ft=perl6 et sw=4
