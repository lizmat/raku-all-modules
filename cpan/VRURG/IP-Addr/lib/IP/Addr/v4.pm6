#! /usr/bin/env false

use v6.c;

=begin pod

=NAME    IP::Addr::v4

=head1 DESCRIPTION

Class implements IPv4 handler.

=head2 Handler-specific methods

=head3 C<broadcast>

Returns C<IP::Addr> object representing broadcast address. Valid for CIDR form only.

=head3 C<next-host>

Similar to C<next> method but doesn't iterate over network and boradcast addresses.

=head3 C<prev-host>

Similar to C<prev> method but doesn't iterate over network and boradcast addresses.

=head3 C<int-boradcast>

Returns integer representation of the broadcast address.

=head3 C<to-octets>

IPv4 alias for C<to-n-tets>.

=end pod

use IP::Addr::Handler;
use IP::Addr::Common;

unit class IP::Addr::v4 does IP::Addr::Handler;

my %addr-class = 
    "0.0.0.0/8" => {
        scope => software,
        description => "current network",
    },
    "10.0.0.0/8" => {
        scope => private,
        description => "local communications within a private network",
    },
    "100.64.0.0/10" => {
        scope => private,
        description => "shared address space for communications between a service provider and its subscribers when using a carrier-grade NAT",
    },
    "127.0.0.0/8" => {
        scope => host,
        description => "loopback addresses to the local host",
    },
    "169.254.0.0/16" => {
        scope => subnet,
        description => "link-local addresses between two hosts on a single link when no IP address is otherwise specified",
    },
    "172.16.0.0/12" => {
        scope => private,
        description => "local communications within a private network",
    },
    "192.0.0.0/24" => {
        scope => private,
        description => "IETF Protocol Assignments",
    },
    "192.0.2.0/24" => {
        scope => documentation,
        description => "documentation and examples",
    },
    "192.88.99.0/24" => {
        scope => internet,
        description => "formerly used for IPv6 to IPv4 relay (included IPv6 address block 2002::/16).",
    },
    "192.168.0.0/16" => {
        scope => private,
        description => "local communications within a private network",
    },
    "198.18.0.0/15" => {
        scope => private,
        description => "benchmark testing of inter-network communications between two separate subnets",
    },
    "198.51.100.0/24" => {
        scope => documentation,
        description => "documentation and examples",
    },
    "203.0.113.0/24" => {
        scope => documentation,
        description => "documentation and examples",
    },
    "224.0.0.0/4" => {
        scope => internet,
        description => "IP multicast",
    },
    "240.0.0.0/4" => {
        scope => internet,
        description => "reserved for future use",
    },
    "255.255.255.255/32" => {
        scope => subnet,
        description => q<reserved for the "limited broadcast" destination address>,
    },
    ;

class v4-actions { ... }
trusts v4-actions;

method new ( :$parent, |args ) {
    self.bless( :$parent ).set( |args )
}

submethod TWEAK ( :$!parent ) { }

sub valid-dotted-subnet ( $m ) {
    my $mask = 0;
    $mask = ( $mask +< 8 ) + $_.Int for $m<ipv4><octet>;
    $mask.base(2) ~~ / ^ '1'* '0'* $ /
}

grammar IPv4-Grammar does IPv4-Basic {

    method TOP (Bool :$validate = False) {
        my $*VALIDATE-IP = $validate;
        self.ip-variants
    }

    rule ip-variants {
        <range> | <cidr> | <ipv4>
    }

    rule range {
        <ipv4> '-' <ipv4>
    }

    token cidr {
        <ipv4> '/' <prefix-len>
    }

    token prefix-len {
            <ipv4> <?{ $*VALIDATE-IP ?? valid-dotted-subnet( $/ ) !! True }>
            | <bits>
    }

    token bits {
        \d ** 1..2 <?{ $*VALIDATE-IP ?? ( $/.Int <= 32 ) !! True }>
    }
}

class v4-actions {
    has $.ip-obj; # The parent IP::Handler object

    method TOP ( $m ) { $m.make( $m.ast ) }
    method ip-variants ( $m ) {
        with $m<ipv4> { $m.make( [ ip, %( ip => .ast ) ] ) }
        with $m<range> { $m.make( [ range,  .ast ] ) }
        with $m<cidr> { $m.make( [ cidr, .ast ] ) }
    }
    method octet ( $m ) { $m.make( $m.Int ) }
    method ipv4 ( $m ) { 
        $m.make( $.ip-obj.to-int( $m<octet>.map: *.ast ) )
    }
    method range ( $m ) { $m.make( { :first( $m<ipv4>[0].ast ), :last( $m<ipv4>[1].ast ) } ) }

    method cidr ( $m ) { $m.make( { :ip( $m<ipv4>.ast ), :prefix-len( $m<prefix-len>.ast ) } ) }

    method bits ( $m ) { $m.make( $m.Int ) }
    multi method prefix-len ( $m where so *<ipv4> ) {
        #note "p-len from ip: ", $m<ipv4>.ast;
        #note "len from mask: ", $.ip-obj!IP::Addr::v4::mask2pfx( $m<ipv4>.ast );
        $m.make( $.ip-obj!IP::Addr::v4::mask2pfx( $m<ipv4>.ast ) );
    }
    multi method prefix-len( $m where so *<bits> ) {
        #note "p-len from bits";
        $m.make( $m<bits>.ast )
    }
}

our sub is-ipv4 ( Str $ip --> Bool ) is export {
    #note IPv4.parse( $ip, args => \(:validate) );
    so IPv4-Grammar.parse( $ip, args => \(:validate) );
}

method broadcast {
    return Nil unless $!form == cidr;
    $.parent.dup-handler( ip => $!last-addr )
}

method next-host {
    return Nil if ( $!form == cidr ) && ( $!addr >= ( $!last-addr - 1 ) );
    self.next;
}

method prev-host {
    return Nil if ( $!form == cidr ) && ( $!addr <= ( $!first-addr + 1 ) );
    self.prev
}

method int-broadcast {
    return Nil unless $!form == cidr;
    $!last-addr
}

method ip-classes ( --> Array ) {
    state @info;
    
    once {
        my @unsorted;
        for %addr-class.kv -> $net, $info {
            my $ip-net = $.parent.dup-handler( $net );
            @info.push: { :net($ip-net), :$info };
        }
    }

    @info
}

method to-octets ( Int:D $addr --> List ) { self.to-n-tets( $addr ) }

method !octets2str( @octs --> Str ) {
    @octs.join('.') 
}

method int2str( Int $addr, *%params --> Str ) { self!octets2str( self.to-n-tets( $addr ), |%params ) }

method addr-len { 32 }

multi method set ( Str:D :$!source! ) {
    #note "Set from Str source";
    my $m = IPv4-Grammar.parse( $!source, :actions( v4-actions.new( :ip-obj( self ) ) ), :args( :validate ) );
    # TODO Exception if parse failed
    self!recalc( $m.ast );
}

method prefix ( :$mask ) {
    if $mask {
        return self.int2str( $!addr ) ~ "/" ~ self.int2str( $!mask )
    }
    self.int2str( $!addr ) ~ "/" ~ self.prefix-len 
}
method version ( --> 4 ) {}
method n-tets ( --> 4 ) { }

=begin pod
=AUTHOR  Vadim Belman <vrurg@cpan.org>
=head1 SEE ALSO

IP::Addr, IP::Addr::Handler

=end pod

# vim: ft=perl6 et sw=4
