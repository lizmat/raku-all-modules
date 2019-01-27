use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Connection;
use OO::Monitors;

unit monitor Net::BGP::Connection-List:ver<0.0.0>:auth<cpan:JMASLAK>;

has Net::BGP::Connection:D %!connections;

method get(Int:D $id) {
    if self.exists($id) {
        return %!connections{$id};
    } else {
        return;
    }
}

method add(Net::BGP::Connection:D $connection -->Nil) {
    %!connections{ $connection.id } = $connection;
}

method remove(Int:D $id -->Nil) {
    %!connections{ $id }:delete;
}

method exists(Int:D $id -->Bool) {
    return %!connections{ $id }:exists;
}

=begin pod

=head1 NAME

Net::BGP::Connection-List - BGP Connection List Object

=head1 SYNOPSIS

  use Net::BGP::Connection-List;

  my $list = Net::BGP::Connection-List.new;
  $list.add($connection);
  $list.remove($connection.id) if $list.exists($connection.id);

=head1 METHODS

=head2 exists(Int:D $id)

  if $list->exists(1) { … }

Returns C<True> if the connection identified with the ID value passed exists.

=head2 get(Int:D $id)

  $list->get(1);

Returns the Connection object associated with the ID (or an undefined value
if none exists).

=head2 add(Net::BGP::Connection:D $connection)

  $list->add($connection);

Adds a new connection to the connection list.

=head2 remove(Int:D $id)

  $list->remove(1);

Removes a connection from the connection list

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.ent>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

