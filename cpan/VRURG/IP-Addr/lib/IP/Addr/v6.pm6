#! /usr/bin/env false

use v6.c;

=begin pod

=NAME    IP::Addr::v6

=head1 SYNOPSIS

    my $ip = IP::Addr.new( "2001::/120", :abbreviated, :compact );
    say $ip;                # 2001::/120

    my $ip = IP::Addr.new( "2001::/120", :abbreviated, :!compact );
    say $ip;                # 2001:0:0:0:0:0:0:0/120

    my $ip = IP::Addr.new( "2001::/120", :!abbreviated, :!compact );
    say $ip;                # 2001:0000:0000:0000:0000:0000:0000:0000/120

    my $ip = IP::Addr.new( "2001:0000:0000:0000:0000:0000:0000:0000/120" );
    say $ip;                # 2001:0000:0000:0000:0000:0000:0000:0000/120

    my $ip = IP::Addr.new( "2001::/120" );
    say $ip;                # 2001::/120

=head1 DESCRIPTION

Class implements IPv4 handler.

When initialized from a string representation of a IPv6 address this handler tries to preserve the original formatting.
E.g. it memorizes whether the source string had abbreviated hextets or was in compact form (contained I<::>). The 
L<#SYNOPSIS> section demonstrates this behavior in the last two examples.

=head2 Attributes

=head3 C<$.scope>

For a scoped IPv6 address this attribute contains its scope (i.e. – interface).

=head3 C<Bool $.abbreviated>

This attribute defines if hextets in string representation of IPv6 address would be in their full 4-digit form or
abbreviated – i.e. leading zeroes dropped. If it is I<False> then C<$.compact> value is ignored when address is
being stringified.

=head3 C<Bool $.compact>

If I<True> then address string representation will have longest streak of zero hextets compacted into I<::>.

=head3 C<Bool $.mapped>

This attribute is set by parser to I<True> if source string represents a IPv4 mapped form of IPv6.

=head2 Methods

=head3 C<to-hextets>

Alias for C<to-n-tets> method.

=end pod

use IP::Addr::Handler;
use IP::Addr::Common;

unit class IP::Addr::v6 does IP::Addr::Handler;

use IP::Addr::v4;

subset Trilean of Any where * ~~ Bool | Any:U;

my %addr-class = 
    "::/0" => {
        scope => routing,
        description => "default route",
    },
    "::/128" => {
        scope => software,
        description => "unspecified address",
    },
    "::1/128" => {
        scope => host,
        description => "loopback address",
    },
    "::ffff:0:0/96" => {
        scope => software,
        description => "IPv4 mapped addresses",
    },
    "::ffff:0:0:0/96" => {
        scope => software,
        description => "IPv4 translated addresses",
    },
    "64:ff9b::/96" => {
        scope => internet,
        description => "IPv4/IPv6 translation",
    },
    "100::/64" => {
        scope => routing,
        description => "discard prefix",
    },
    "2001::/32" => {
        scope => internet,
        description => "Teredo tunneling",
    },
    "2001:20::/28" => {
        scope => software,
        description => "ORCHIDv2",
    },
    "2001:db8::/32" => {
        scope => documentation,
        description => "used in documentation and examples",
    },
    "2002::/16" => {
        scope => internet,
        description => "6to4 addressing scheme (deprecated)",
    },
    "fc00::/7" => {
        scope => private,
        description => "private network",
    },
    "fe80::/10" => {
        scope => link,
        description => "link-local",
    },
    "ff00::/8" => {
        scope => internet,
        description => "multicast address",
    },
    ;

has $.scope;

# Compact IPv6 form without leading zeroes and zero hextets compacted
has Trilean $.abbreviated is rw;
# Sub-modification of abbreviated. If False then zero hextets aren't compacted. Makes no sense if $.abbreviated is False
has Trilean $.compact is rw;

# IPv4 mapped address
has Bool $.mapped is rw = False;

#no precompilation;
#use Grammar::Tracer;

method new ( :$parent, |args ) {
    self.bless( :$parent, |args.hash ).set( |args )
}

submethod TWEAK ( :$!parent, :$!abbreviated?, :$!compact?, :$!mapped = False ) { }

grammar IPv6-Grammar does IPv4-Basic {
    rule TOP {
        :my $*MAX-HEXTETS = 8;
        <v6-variants>
    }

    rule v6-variants {
        <cidr> | <range> | <scoped> | <ipv6>
    }

    token ipv6 {
        <full-v6>
        | <mapped-v6>
        | <compressed-v6>
    }

    token cidr {
        <ipv6> '/' <prefix-len>
    }

    rule range {
        <ipv6> '-' <ipv6>
    }

    token scoped {
        <ipv6> '%' $<scope>=( \S+ )
    }

    token full-v6 {
        <hextet> ** { $*MAX-HEXTETS } % ':'
    }

    sub hextets2int ( @hx ) {
        my $pfx = 0;
        $pfx = ( $pfx +< 16 ) +| $_ for @hx;
        $pfx
    }

    token mapped-v6 {
        :temp $*MAX-HEXTETS = 6;
        [
            <full-v6> <?{
                hextets2int( $/<full-v6><hextet>.map: { (~$_).parse-base( 16 ) } ) == 
                    0xffff | 0xffff0000 | 0x64ff9b0000000000000000
            }> ':'
            | [
                    <compressed-v6> <?{ (~$/).ends-with( '::' ) }> # when compressed ends with ::
                    | <compressed-v6> ':'
            ] <?{ 
                my @pfx = $/<compressed-v6><sub-v6>[0]<hextet>.map: { (~$_).parse-base(16) };
                my @sfx = $/<compressed-v6><sub-v6>[1]<hextet>.map: { (~$_).parse-base(16) };
                my @zero = 0 xx ($*MAX-HEXTETS - @pfx.elems - @sfx.elems);
                hextets2int( (@pfx, @zero, @sfx).flat ) ==
                    0xffff | 0xffff0000 | 0x64ff9b0000000000000000
            }>
        ]
        <ipv4>
    }

    token compressed-v6 {
        <sub-v6> $<double-col>='::' <sub-v6> 
        <?{ ($/<sub-v6>[0]<hextet>.elems + $/<sub-v6>[1]<hextet>.elems) < $*MAX-HEXTETS }>
    }

    token sub-v6 {
        <hextet> ** { ^($*MAX-HEXTETS - 1) } % ':'
    }

    token hextet {
        <xdigit> ** 1..4 <!before '.' >
    }

    token prefix-len {
        <digit> ** ^4 <?{ $/.Int <= 128 }>
    }
}

class v6-actions {
    has $.ip-obj;
    has $!abbreviated = False;
    has $!compact = False;
     
    method TOP ( $m ) { $m.make( $m<v6-variants>.ast ) }
    method v6-variants ( $m ) {

        state %form-map = :cidr(cidr), :range(range), :ipv6(ip), :scoped(ip);

        for <cidr range ipv6 scoped> -> $form {
            with $m{ $form } {
                my $ast = $form eq 'ipv6' ?? %( ip => .ast ) !! .ast;
                $m.make( [ %form-map{ $form }, $ast ] );
                last;
            }
        }
    }

    method ipv6 ( $m ) {
        my @ip;
        for <full-v6 mapped-v6 compressed-v6> -> $form {
            with $m{ $form } {
                #note "IPv6 from: ", $form;
                @ip = .ast;
                last;
            }
        }
        $.ip-obj.abbreviated //= $!abbreviated;
        $.ip-obj.compact //= $!compact;
        $m.make( $.ip-obj.to-int( @ip ) );
    }

    method cidr ( $m ) {
        $m.make(
            {
                :ip( $m<ipv6>.ast ),
                :prefix-len( $m<prefix-len>.ast ),
            }
        );
    }

    method range ( $m ) {
        $m.make( { 
            :first( $m<ipv6>[0].ast ), 
            :last( $m<ipv6>[1].ast ) 
        } ) 
    }

    method scoped ( $m ) {
        $m.make( {
            ip => $m<ipv6>.ast,
            scope => ~$m<scope>,
        } );
    }

    method mapped-v6 ( $m ) {
        my @pfx;
        my $s = "full-v6";
        with $m<full-v6> { @pfx = .ast }
        with $m<compressed-v6> { @pfx = .ast }
        my @ipv4 = $m<ipv4><octet>.map: *.Int;
        #note "V4 MAP:", @ipv4;
        $m.make( [ ( @pfx, @ipv4[0] * 256 + @ipv4[1], @ipv4[2] * 256 + @ipv4[3] ).flat ] );
        $.ip-obj.mapped = True;
    }

    method compressed-v6 ( $m ) {
        my @start = $m<sub-v6>[0].ast;
        my @end = $m<sub-v6>[1].ast;
        my @zeroed = 0 xx ($*MAX-HEXTETS - @start.elems - @end.elems);
        $m.make( [ ( @start, @zeroed, @end ).flat ] );
        # Abbreviation default depends on wether we've met any abbreviated hextet
        $!abbreviated = $!compact = True;
    }

    method full-v6 ( $m ) {
        $m.make( ($m<hextet>.map: *.ast).List );
        $!compact = False;
    }

    method sub-v6 ( $m ) {
        $m.make( ($m<hextet>.map: *.ast).List );
    }

    method hextet ( $m ) {
        $!abbreviated ||= ( (~$m).chars < 4 );
        $m.make( parse-base( ~$m, 16 ) )
    }

    method prefix-len ( $m ) {
        $m.make( $m.Int );
    }
}

proto method set (|) {
    self!reset; 
    {*}
    $!abbreviated //= True;
    $!compact //= True;
    self
}

multi method set ( Str:D :$!source! ) {
    my $m = IPv6-Grammar.parse( $!source, :actions( v6-actions.new( :ip-obj( self ) ) ) );
    die "Not a IPv6 address: '$!source'" unless $m;
    # TODO Exception if parse failed
    self!recalc( $m.ast );
}

method n-tets ( --> 8 ) { }

our sub is-ipv6 ( Str $ip --> Bool ) is export {
    so IPv6-Grammar.parse( $ip );
}

method version ( --> 6 ) { }

method to-hextets ( Int:D $addr --> List ) { self.to-n-tets( $addr ) }

method !hextets2str( @hextets, :$abbreviated = $!abbreviated, :$compact = $!compact, :$uc = False ) {
    my @hx;
    my ( $v6, $v4 );

    if $!mapped {
        @hx = @hextets[0..5];
        $v4 = ~ $.parent.WHAT.new( :ip( self.to-int( @hextets[6..7] ) ), :v4 );
    } else {
        @hx = @hextets;
    }

    if $abbreviated {

        sub unite ( @h ) { @h.map( *.base(16) ).join(':') }

        #note "Using compact ( $!source )? ", $!compact;

        if $compact {
            my ( $zpos, $max-pos ); 
            my ( $zlen, $max-len ) = 0, 0;

            sub set-max {
                if $zlen > 1 & $max-len {
                    $max-pos = $zpos;
                    $max-len = $zlen;
                }
            }

            for 0...@hx.end -> $i {
                if @hx[$i] == 0 {
                    if $zlen > 0 {
                        $zlen++;
                    }
                    else {
                        $zpos = $i;
                        $zlen++;
                    }
                }
                elsif $zlen > 0 {
                    set-max;
                    $zlen = 0;
                }
            }

            set-max;

            if $max-len > 0 {
                my ($start, $end ) = "", "";
                #note "HX:", @hx;
                #note "max-pos:", $max-pos;
                $start = unite( @hx[ 0..( $max-pos - 1 ) ] ) if $max-pos > 0;
                my $end-pos = $max-pos + $max-len;
                $end = unite( @hx[ $end-pos..(*-1) ] ) if $end-pos <= @hx.end;
                $v6 = $start ~ '::' ~ $end;
            }
        }

        # Will also be set if $compact True but no sequence of zeroes found
        $v6 //= unite( @hx );
    }
    else {
        $v6 = @hx.map( *.fmt( '%04x' ) ).join(':');
    }

    $v6 ~= ':' ~ $v4 if $!mapped;

    $uc ?? $v6.uc !! $v6.lc
}

method int2str ( Int:D $addr, *%params --> Str ) { 
    self!hextets2str( self.to-n-tets( $addr ), |%params )
}

method addr-len { 128 }

method prefix {
    self.int2str( $!addr ) ~ "/" ~ $!prefix-len;
}

method ip-classes ( --> Array ) {
    state @info;
    
    once {
        my @unsorted;
        for %addr-class.kv -> $net, $info {
            my $ip-net = $.parent.dup( $net );
            @info.push: { :net($ip-net), :$info };
        }
    }

    @info
}

=begin pod
=head1 EXAMPLES

    my $ip = IP::Addr.new( "2001::/120", :abbreviated, :!compact );
    say $ip;                # 2001:0:0:0:0:0:0:0/120
    $ip.abbreviated = False;
    say $ip;                # 2001:0000:0000:0000:0000:0000:0000:0000/120
    # Won't be in effect due to abbreviation being turned off
    $ip.compact = True;     
    say $ip;                # 2001:0000:0000:0000:0000:0000:0000:0000/120
    # Now both abbreviation and compactness will be activated
    $ip.abbreviated = True;
    say $ip;                # 2001::/120

=AUTHOR  Vadim Belman <vrurg@cpan.org>
=head1 SEE ALSO

IP::Addr, IP::Addr::Handler

=end pod

# vim: ft=perl6 et sw=4
