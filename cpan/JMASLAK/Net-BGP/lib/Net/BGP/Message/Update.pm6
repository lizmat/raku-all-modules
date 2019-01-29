use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

use Net::BGP::Conversions;
use Net::BGP::IP;
use Net::BGP::CIDR;
use Net::BGP::Message;
use Net::BGP::Parameter;
use Net::BGP::Path-Attribute;
use Net::BGP::Path-Attribute::Aggregator;
use Net::BGP::Path-Attribute::AS-Path;
use Net::BGP::Path-Attribute::AS4-Aggregator;
use Net::BGP::Path-Attribute::AS4-Path;
use Net::BGP::Path-Attribute::Atomic-Aggregate;
use Net::BGP::Path-Attribute::Cluster-List;
use Net::BGP::Path-Attribute::Community;
use Net::BGP::Path-Attribute::Generic;
use Net::BGP::Path-Attribute::Local-Pref;
use Net::BGP::Path-Attribute::MED;
use Net::BGP::Path-Attribute::MP-NLRI;
use Net::BGP::Path-Attribute::MP-Unreachable;
use Net::BGP::Path-Attribute::Next-Hop;
use Net::BGP::Path-Attribute::Origin;
use Net::BGP::Path-Attribute::Originator-ID;

use StrictClass;
unit class Net::BGP::Message::Update:ver<0.1.0>:auth<cpan:JMASLAK>
    is Net::BGP::Message
    does StrictClass;

has Bool:D $.asn32 is required;

has Str   $.cached-next-hop;
has Str   $.cached-as16-path;
has Str   $.cached-as32-path;
has Str   $.cached-origin;
has Str:D @.cached-community-list;
has Bool  $.cached-atomic-aggregate;
has Int   $.cached-aggregator-asn;
has Str   $.cached-aggregator-ip;
has Int   $.cached-as4-aggregator-asn;
has Str   $.cached-as4-aggregator-ip;

method new() {
    die("Must use from-raw or from-hash to construct a new object");
}

method implemented-message-code(--> Int) { 2 }
method implemented-message-name(--> Str) { "UPDATE" }

method message-code() { 2 }
method message-name() { "UPDATE" }

# Stuff unique to UPDATE
method withdrawn-start(-->Int:D)  { 3 }
method withdrawn-length(-->Int:D) { nuint16($.data.subbuf(1, 2)) }

method path-start(-->Int:D)  { 5 + self.withdrawn-length }
method path-length(-->Int:D) { nuint16( $.data.subbuf(3+self.withdrawn-length, 2) ) }

method nlri-start(-->Int:D)  { self.path-start() + self.path-length; }
method nlri-length(-->Int:D) { $.data.bytes - self.nlri-start() + 1; }

has Net::BGP::Path-Attribute:D @!cached-path-attributes;
method path-attributes(-->Array[Net::BGP::Path-Attribute:D]) {
    return @!cached-path-attributes if @!cached-path-attributes;

    @!cached-path-attributes = Net::BGP::Path-Attribute.path-attributes(
        self.data.subbuf( self.path-start, self.path-length),
        :$!asn32
    );
    $!cached-atomic-aggregate = False;
    for @!cached-path-attributes -> $attr {
        given $attr {
            when Net::BGP::Path-Attribute::Next-Hop {
                $!cached-next-hop           = $attr.ip;
            }
            when Net::BGP::Path-Attribute::AS-Path {
                $!cached-as16-path          = $attr.as-path;
            }
            when Net::BGP::Path-Attribute::AS4-Path {
                $!cached-as32-path          = $attr.as4-path;
            }
            when Net::BGP::Path-Attribute::Origin {
                $!cached-origin             = $attr.origin;
            }
            when Net::BGP::Path-Attribute::Community {
                @!cached-community-list     = $attr.community-list;
            }
            when Net::BGP::Path-Attribute::Atomic-Aggregate {
                $!cached-atomic-aggregate   = True;
            }
            when Net::BGP::Path-Attribute::Aggregator {
                $!cached-aggregator-asn     = $attr.asn;
                $!cached-aggregator-ip      = $attr.ip;
            }
            when Net::BGP::Path-Attribute::AS4-Aggregator {
                $!cached-as4-aggregator-asn = $attr.asn;
                $!cached-as4-aggregator-ip  = $attr.ip;
            }
        }
    }
    return @!cached-path-attributes;
}

method Str(-->Str) {
    my @lines;
    push @lines, "UPDATE";

    my $withdrawn = self.withdrawn;
    if $withdrawn.elems {
        push @lines, "WITHDRAWN: " ~ $withdrawn».Str ==> join(" ");
    }

    my $nlri = self.nlri;
    if $nlri.elems {
        push @lines, "NLRI: " ~ $nlri.join(" ");
    }
   
    my $path = self.path;
    push @lines, "Path: $path" if $path.defined;

    my $nh = self.next-hop;
    push @lines, "Next-Hop: $nh" if $nh.defined;

    my @comm = self.community-list;
    push @lines, "Communities: " ~ @comm.join(" ") if @comm.elems;

    push @lines, "Atomic-Aggregate" if self.atomic-aggregate;

    if self.aggregator-asn.defined {
        push @lines, "Aggregator: ASN {self.aggregator-asn} by " ~
            self.aggregator-ip;
    }

    my $path-attributes = self.path-attributes;
    for $path-attributes.sort( { $^a.path-attribute-code <=> $^b.path-attribute-code } ) -> $attr {
        next if $attr ~~ Net::BGP::Path-Attribute::AS-Path;
        next if $attr ~~ Net::BGP::Path-Attribute::AS4-Path;
        next if $attr ~~ Net::BGP::Path-Attribute::Origin;
        next if $attr ~~ Net::BGP::Path-Attribute::Community;
        next if $attr ~~ Net::BGP::Path-Attribute::Next-Hop;
        next if $attr ~~ Net::BGP::Path-Attribute::Atomic-Aggregate;
        next if $attr ~~ Net::BGP::Path-Attribute::Aggregator;
        next if $attr ~~ Net::BGP::Path-Attribute::AS4-Aggregator;

        push @lines, "  ATTRIBUTE: " ~ $attr.Str;
    }

    return join("\n      ", @lines);
}

method from-raw(buf8:D $raw where $raw.bytes ≥ 2, Bool:D :$asn32) {
    my $obj = self.bless(:data( buf8.new($raw) ), :$asn32);

    $obj.nlri-length();  # Just make sure we can read everything.
    # XXX Need to validate components

    return $obj;
};

method from-hash(%params is copy, Bool:D :$asn32) {
    my @REQUIRED = «
        withdrawn origin as-path as4-path next-hop med local-pref
        atomic-aggregate originator-id cluster-list community nlri
        address-family path-attributes aggregator-ip aggregator-asn
    »;

    %params<withdrawn>        //= [];
    %params<origin>           //= '?';
    %params<as-path>          //= '';
    %params<as4-path>         //= '';
    %params<next-hop>         //= '';
    %params<local-pref>       //= '';
    %params<atomic-aggregate> //= False;
    %params<med>              //= '';
    %params<community>        //= [];
    %params<originator-id>    //= '';
    %params<cluster-list>     //= '';
    %params<nlri>             //= [];
    %params<address-family>   //= 'ipv4';
    %params<path-attributes>  //= [];
    %params<aggregator-asn>   //= Nil;
    %params<aggregator-ip>    //= '';

    # Delete unnecessary option
    if %params<message-code>:exists {
        if (%params<message-code> ≠ 2) { die("Invalid message type for UPDATE"); }
        %params<message-code>:delete
    }
    if %params<message-name>:exists {
        if (%params<message-name> ≠ 'UPDATE') {
            die("Invalid message type for UPDATE");
        }
        %params<message-name>:delete
    }

    if @REQUIRED.sort.list !~~ %params.keys.sort.list {
        die("Did not provide proper options");
    }

    if %params<address-family> ne 'ipv4' and %params<address-family> ne 'ipv6' {
        die("Cannot understand address family");
    }

    # Prefix parts
    my $withdrawn = buf8.new;
    if %params<address-family> eq 'ipv4' {
        for @(%params<withdrawn>) -> $w {
            $withdrawn.append: Net::BGP::CIDR.from-str($w).to-packed;
        }
    }

    my $nlri = buf8.new;
    if %params<address-family> eq 'ipv4' {
        for @(%params<nlri>) -> $n {
            $nlri.append: Net::BGP::CIDR.from-str($n).to-packed;
        }
    }

    # Path Attributes
    my $path-attr = buf8.new;
    if %params<origin> ne '' {
        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'Origin',
                origin              => %params<origin>,
            },
            :$asn32
        ).raw;
    }

    $path-attr.append: Net::BGP::Path-Attribute.from-hash(
        {
            path-attribute-name => 'AS-Path',
            as-path             => %params<as-path>,
        },
        :$asn32
    ).raw;

    if %params<address-family> eq 'ipv4' and %params<next-hop> ne '' {
        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'Next-Hop',
                next-hop            => %params<next-hop>,
            },
            :$asn32
        ).raw;
    }

    if %params<med> ne '' {
        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'MED',
                med                 => %params<med>,
            },
            :$asn32
        ).raw;
    }

    if %params<local-pref> ne '' {
        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'Local-Pref',
                local-pref          => %params<local-pref>,
            },
            :$asn32
        ).raw;
    }

    if %params<atomic-aggregate> {
        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'Atomic-Aggregate',
            },
            :$asn32
        ).raw;
    }

    if %params<aggregator-ip> ne '' {
        die("Must define aggregator ASN") if ! %params<aggregator-asn>.defined;

        # We write 23456 for 32 bit ASNs
        my $aggregate-asn = %params<aggregator-asn>;
        if $aggregate-asn ≥ 2¹⁶ and ! $asn32 { $aggregate-asn = 23456 }

        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'Aggregator',
                asn                 => $aggregate-asn,
                ip                  => %params<aggregator-ip>,
            },
            :$asn32
        ).raw;
    }

    if %params<community>.elems {
        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'Community',
                community           => %params<community>,
            },
            :$asn32
        ).raw;
    }

    if %params<originator-id> ne '' {
        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'Originator-ID',
                originator-id       => %params<originator-id>,
            },
            :$asn32
        ).raw;
    }

    if %params<cluster-list> ne '' {
        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'Cluster-List',
                cluster-list        => %params<cluster-list>,
            },
            :$asn32
        ).raw;
    }
    
    if %params<address-family> eq 'ipv6' {
        if %params<nlri>.elems {
            $path-attr.append: Net::BGP::Path-Attribute.from-hash(
                {
                    path-attribute-name => 'MP-NLRI',
                    address-family      => %params<address-family>,
                    next-hop            => %params<next-hop>,
                    nlri                => %params<nlri>,
                },
                :$asn32
            ).raw;
        };
        if %params<withdrawn>.elems {
            $path-attr.append: Net::BGP::Path-Attribute.from-hash(
                {
                    path-attribute-name => 'MP-Unreachable',
                    address-family      => %params<address-family>,
                    next-hop            => %params<next-hop>,
                    withdrawn           => %params<withdrawn>,
                },
                :$asn32
            ).raw;
        };
    }
   
    if %params<as4-path> eq '' { 
        if !$asn32 and %params<as-path>.comb(/ <[0..9]>+ /).first(* ≥ 2¹⁶).defined {
            $path-attr.append: Net::BGP::Path-Attribute.from-hash(
                {
                    path-attribute-name => 'AS4-Path',
                    as4-path            => %params<as-path>,
                },
                :asn32
            ).raw;
        }
    } else {
        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'AS4-Path',
                as4-path            => %params<as4-path>,
            },
            :asn32
        ).raw;
    }

    if (!$asn32) && (%params<aggregator-ip> ne '')
        && ( %params<aggregator-asn> ≥ 2¹⁶ )
    {
        die("Must define aggregator ASN") if ! %params<aggregator-asn>.defined;

        $path-attr.append: Net::BGP::Path-Attribute.from-hash(
            {
                path-attribute-name => 'AS4-Aggregator',
                asn                 => %params<aggregator-asn>,
                ip                  => %params<aggregator-ip>,
            },
            :$asn32
        ).raw;
    }

    my @attrs = @(%params<path-attributes>);
    for @attrs -> $attr {
        $path-attr.append: Net::BGP::Path-Attribute.from-hash( $attr, :$asn32 ).raw;
    }

    my $msg = buf8.new( 2 );                        # Message type
    $msg.append(nuint16-buf8( $withdrawn.bytes ) ); # Length of withdraw
    $msg.append($withdrawn);                        # Withdrawn
    $msg.append(nuint16-buf8( $path-attr.bytes ) ); # Length of path attributes
    $msg.append($path-attr);                        # Path attributes
    $msg.append($nlri);                             # NLRI

    return self.bless(:data( buf8.new($msg) ), :$asn32);
};

has Array[Net::BGP::CIDR:D] $!cached-nlri;
method nlri(-->Array[Net::BGP::CIDR:D]) {
    return $!cached-nlri if $!cached-nlri;

    $!cached-nlri = Net::BGP::CIDR.packed-to-array(
        $.data.subbuf( self.nlri-start, self.nlri-length )
    );
    return $!cached-nlri;
}

has Array[Net::BGP::CIDR:D] $!cached-nlri6;
method nlri6(-->Array[Net::BGP::CIDR:D]) {
    return $!cached-nlri6 if $!cached-nlri6;

    $!cached-nlri6 = Array[Net::BGP::CIDR:D].new;
    my $attr = self.path-attributes.first( { $^a ~~ Net::BGP::Path-Attribute::MP-NLRI } );
    if $attr.defined {
        my @cidrs = $attr.nlri-cidrs;
        $!cached-nlri6.push(|@cidrs) if @cidrs;
    }

    return $!cached-nlri6;
}

has Str $!cached-next-hop6;
method next-hop6(-->Str) {
    return $!cached-next-hop6 if $!cached-next-hop6;

    my $attr = self.path-attributes.first(
        { $^a ~~ Net::BGP::Path-Attribute::MP-NLRI }
    );
    $!cached-next-hop6 = $attr.next-hop-global;

    return $!cached-next-hop6;
}

method withdrawn(-->Array[Net::BGP::CIDR:D]) {
    Net::BGP::CIDR.packed-to-array( $.data.subbuf( self.withdrawn-start(), self.withdrawn-length() ));
}

method withdrawn6(-->Array[Net::BGP::CIDR:D]) {
    my Net::BGP::CIDR:D @ret;

    my @attrs = self.path-attributes.grep(
        { $^a ~~ Net::BGP::Path-Attribute::MP-Unreachable }
    );
    for @attrs -> $attr {
        my @cidrs = $attr.withdrawn-cidrs;
        @ret.push(|@cidrs) if @cidrs.elems;
    }

    return @ret;
}

method as-path(-->Str) {
    self.path-attributes.sink;

    if self.asn32 {
        # We don't need to look at AS4-Path.
        return $!cached-as16-path; # A bit of a misnomer in name XXX
    } else {
        # So we're a 16 bit ASN BGP speaker.  Let's look at AS4.
        
        # Do we have an AS4-Path?
        return $!cached-as16-path if ! $!cached-as32-path;

        my $as4  = self.path-attributes.first( * ~~ Net::BGP::Path-Attribute::AS4-Path );
        my $as   = self.path-attributes.first( * ~~ Net::BGP::Path-Attribute::AS-Path );

        # XXX We need to look for AS4_Aggregator and check that
        # Aggregator, if found, is 23456.
        
        if $as.path-length < $as4.path-length {
            return $as.as-path;
        } elsif $as.path-length == $as4.path-length {
            return $as4.as4-path;
        } else {
            my $prefix = $as.as-path-first($as.path-length - $as4.path-length);
            return "$prefix " ~ $as4.as4-path;
        }
    }

}

method origin(-->Str) {
    self.path-attributes.sink;
    return $!cached-origin;
}

method path(-->Str) {
    my $as-path = self.as-path;
    return Str unless $as-path.defined;

    my $origin = self.origin // '?';
    return $origin if $as-path eq '';

    return "$as-path $origin";
}

method community-list(-->Array[Str:D]) {
    self.path-attributes.sink;
    return @!cached-community-list;
}

method atomic-aggregate(-->Bool:D) {
    self.path-attributes.sink;
    return $!cached-atomic-aggregate.so;
}

method aggregator-asn(-->Int) {
    self.path-attributes.sink;

    if (! $!asn32) && $!cached-as4-aggregator-asn.defined {
        return $!cached-as4-aggregator-asn;
    } else {
        return $!cached-aggregator-asn;
    }
}

method aggregator-ip(-->Str) {
    self.path-attributes.sink;

    if (! $!asn32) && $!cached-as4-aggregator-ip.defined {
        return $!cached-as4-aggregator-ip;
    } else {
        return $!cached-aggregator-ip;
    }
}

method next-hop(-->Str) {
    return $!cached-next-hop if $!cached-next-hop.defined;
    my $nh = self.path-attributes.first( * ~~ Net::BGP::Path-Attribute::Next-Hop );
    return unless $nh.defined;
    
    return $!cached-next-hop = $nh.ip;
}

method raw() { return $.data; }


# Register handler
INIT { Net::BGP::Message.register: Net::BGP::Message::Update }

=begin pod

=head1 NAME

Net::BGP::Message::Update - BGP UPDATE Message

=head1 SYNOPSIS

  # We create generic messages using the parent class.

  use Net::BGP::Message;

  my $msg = Net::BGP::Message.from-raw( $raw );  # Might return a child crash

=head1 DESCRIPTION

UPDATE BGP message type

=head1 Constructors

=head2 from-raw

Constructs a new object for a given raw binary buffer.

=head2 from-hash

This simply throws an exception, since the hash format of a generic message
is not designed.

=head1 Methods

=head2 message-name

Returns a string that describes what message type the command represents.

Currently understood types include C<UPDATE>.

=head2 message-code

Contains an integer that corresponds to the message-code.

=head nlri

Returns an array of L<Net::BGP::CIDR> objects for IPv4 addresses in the NLRI
section of the BGP message (I.E. BGP route advertisements).

=head nlri6

Returns an array of L<Net::BGP::CIDR> objects for IPv6 addresses announced in
this BGP message.

=head withdrawn

Returns an array of L<Net::BGP::CIDR> objects for IPv4 prefixes withdrawn by
this BGP message.

=head withdrawn6

Returns an array of L<Net::BGP::CIDR> objects for IPv6 prefixes withdrawn by
this BGP message.

=head2 origin

Returns the origin present in this message.

=head as-path

Returns a string representation of the AS path.

=head path

Returns a string representation of the AS path along with the origin type (I.E.
IGP, EGP, or unknown).

=head2 path-attributes

Returns an array of path attributes.

=head2 community-list

Returns an array of strings representing the communities in the BGP Community
attribute.

=head2 atomic-aggregate

Returns true if the atomic aggregate path attribute is present.  Returns
false otherwise.

=head2 aggregator-ip

Returns the BGP ID of the host that aggregated this route. Returns an undefined
value if the route is not aggregated.

=head2 aggregator-asn

Returns the ASN of the host that aggregated this route. Returns an undefined
value if the route is not aggregated.

=head2 raw

Returns the raw (wire format) data for this message.

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
