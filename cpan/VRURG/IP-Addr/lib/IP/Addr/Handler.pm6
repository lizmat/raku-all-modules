#! /usr/bin/env false

use v6.c;

=begin pod

=NAME    IP::Addr::Handler

=head1 DESCRIPTION

Base role for IP version classes.

Most of the methods provided by this role are documented in U<HANDLER METHODS> section of C<IP::Addr> documentation.

=head2 Attributes

=head3 C<Str $.source>

If object was initialized with a string then this attribute contains that string. Propagaded into new objects created
using C<IP::Addr> C<dup> and C<dup-handler> methods. In other words, most of the methods/operators returning a new 
object would propagade this attribute into it.

=head3 C<IP-FORM $.form>

Form of the current IP object. See C<IP::Addr::Common> and C<IP::Addr>.

=head3 C<Int $.prefix-len>

IP address prefix length. For ranges it would be 0 and for single IPs it would be equal to the result of C<addr-len>
method.

=end pod

use IP::Addr::Common;

my %bitcap-mask = (0..128).map: { $_ => 2**$_ - 1 }; # Mask for each bit capacity

unit role IP::Addr::Handler;

has $.parent is required is rw; # IP::Addr object

has Str $.source;
has IP-FORM $.form;
has Int $!addr;
has Int $.prefix-len;
has Int $!first-addr;
has Int $!last-addr;
# The following two are formally not used by IPv6 but would be calculated anyway.
has Int $!mask;
has Int $!wildcard;

# Address arithmetics specific attributes
has Int $!addr-bits = self.addr-len; # 32 for IPv4 and 128 for IPv6
has Int $!n-tet-count = self.n-tets;
has Int $!n-tet-size = (2 ** ( $!addr-bits / $!n-tet-count )).Int; # Size of octets or hextets in address (max-value+1)

=begin pod

=head2 Required Methods

=end pod

#| Must return a string containing formatted IP address with prefix length.
method prefix { ... }
#| Must return a number representing IP object version. I.e. I<4> for IPv4 and I<6> for IPv6.
method version { ... }
#| Described in IP::Addr documentation
method ip-classes { ... }
#| Formats an integer representation of IP address into string
method int2str ( Int ) { ... }
#| Returns number of bits in address
method addr-len { ... }
#| Returns number of octets/hextets in address
method n-tets { ... }

proto method set (|) {
    self!reset; 
    {*}
    self
}

multi method set ( Str:D $source ) { samewith( :$source ) }

multi method set ( Int:D :$ip!, Int:D :$prefix-len! ) {
    #note "Set from Int ip / Int prefix";
    self!recalc( [ cidr, { :$ip, :$prefix-len } ] )
}

multi method set ( Int:D :$first!, Int:D :$last!, Int :$ip? ) {
    #note "+++++ Set from Int first / Int last";
    self!recalc( [ range,  { :$first, :$last } ] );
    $!addr = $ip if $ip.defined && ( $ip >= $!first-addr ) && ( $ip <= $!last-addr );
}

multi method set( Int:D :$ip! ) {
    #note "Set from Int ip";
    self!recalc( [ ip, { ip => $ip } ] )
}

multi method set( Int:D @octets where *.elems == $!n-tet-count ) {
    samewith( self.to-int( @octets ) )
}

method bitcap( Int $i, Int $bits = self.addr-len ) is export {
    $i +& %bitcap-mask{ $bits } 
}

method ip       { $.parent.dup-handler( ip => $!addr ) }
method first-ip { $.parent.dup-handler( ip => $!first-addr ) }
method last-ip  { $.parent.dup-handler( ip => $!last-addr ) }
method network  { $.parent.dup-handler( ip => $!first-addr, :$!prefix-len ) }
method mask     ( --> Str ) { self.int2str( $!mask ) }
method wildcard ( --> Str ) { self.int2str( $!wildcard ) }
method size     ( --> Int ) { $!last-addr - $!first-addr + 1 }

method int-ip       ( --> Int ) { $!addr }
method int-first-ip ( --> Int ) { $!first-addr }
method int-last-ip  ( --> Int ) { $!last-addr }
method int-mask     ( --> Int ) { $!mask }
method int-wildcard ( --> Int ) { $!wildcard }

method !fit-into-range {
    return if $!form == ip; # No need to fix a single IP
    $!addr = $!last-addr if $!addr > $!last-addr;
    $!addr = $!first-addr if $!addr < $!first-addr;
}

method inc {
    $!addr++;
    self!fit-into-range;
    $.parent
}
method succ { self.inc }
method dec {
    $!addr--;
    self!fit-into-range;
    $.parent
}
method pred { self.dec }
method add ( Int:D $count ) {
    $!addr += $count;
    self!fit-into-range;
    self.parent
}

sub term:<IP::Addr> () { once require IP::Addr }

method !same-type ( $ip where * ~~ IP::Addr ) { 
    X::IPAddr::TypeCheck.new.throw( :ip-list( self.parent, $ip ) ) unless self.version == $ip.version;
}

proto method eq (|) { * }
multi method eq ( ::?CLASS:D $ip --> Bool ) {
    if $!form eq $ip.form {
        if $!form == range {
            return so ( ( $!first-addr == $ip.int-first-ip ) and ( $!last-addr == $ip.int-last-ip ) );
        }
        return so ( ( $!addr == $ip.int-ip ) and ( $!prefix-len == $ip.prefix-len ) )
    }
    False;
}
multi method eq ( Str $addr --> Bool ) {
    samewith( self.WHAT.new( $addr ) )
}
multi method eq ( $ip where { $_.defined and $_ ~~ IP::Addr } --> Bool ) {
    self!same-type( $ip );
    samewith( $ip.handler )
}

proto method lt (|) { * }
multi method lt ( ::?CLASS:D $ip --> Bool ) {
    $!addr < $ip.int-ip 
}
multi method lt ( Str $addr --> Bool ) { samewith( self.WHAT.new( $addr ) ) }
multi method lt ( $ip where { $_.defined and $_ ~~ IP::Addr } --> Bool ) {
    self!same-type( $ip );
    samewith( $ip.handler ) 
}

proto method gt (|) { * }
multi method gt ( ::?CLASS:D $ip --> Bool ) {
    $!addr > $ip.int-ip 
}
multi method gt ( Str $addr --> Bool ) { samewith( self.WHAT.new( $addr ) ) }
multi method gt ( $ip where { $_.defined and $_ ~~ IP::Addr } --> Bool ) {
    self!same-type( $ip );
    samewith( $ip.handler ) 
}

proto method cmp (|) { * }
multi method cmp ( ::?CLASS:D $ip --> Order ) {
    ( $!addr || $!first-addr ) cmp ( $ip.int-ip || $ip.int-first-ip ); 
}
multi method cmp ( Str:D $addr --> Order ) { samewith( self.WHAT.new( $addr ) ) }
multi method cmp ( $ip where { $_.defined and $_ ~~ IP::Addr } --> Bool ) {
    self!same-type( $ip );
    samewith( $ip.handler ) 
}

proto method contains (|) { * }
multi method contains ( ::?CLASS:D $ip --> Bool ) {
    ( $ip.int-first-ip >= $!first-addr ) && ( $ip.int-last-ip <= $!last-addr );
}
multi method contains ( Str $addr --> Bool ) { samewith( self.WHAT.new( $addr ) ) }
multi method contains ( $ip where { $_.defined and $_ ~~ IP::Addr } --> Bool ) {
    self!same-type( $ip );
    samewith( $ip.handler ) 
}

proto method overlaps (|) { * }
multi method overlaps ( ::?CLASS:D $ip --> Bool ) {
    return 
        ( $!first-addr ≥ $ip.int-first-ip and $!first-addr ≤ $ip.int-last-ip ) ||
        ( $!last-addr ≥ $ip.int-first-ip and $!last-addr ≤ $ip.int-last-ip ) ||
        ( $ip.int-first-ip ≥ $!first-addr and $ip.int-first-ip ≤ $!last-addr ) ||
        ( $ip.int-last-ip ≥ $!first-addr and $ip.int-last-ip ≤ $!last-addr ) 
}
multi method overlaps ( Str $addr --> Bool ) { samewith( self.WHAT.new( $addr ) ) }
multi method overlaps ( $ip where { $_.defined and $_ ~~ IP::Addr } --> Bool ) {
    self!same-type( $ip );
    samewith( $ip.handler ) 
}

method first {
    my $dup;
    given $!form {
        when range {
            return $.parent.dup-handler( :first( $!first-addr ), :last( $!last-addr ) );
        }
        when cidr {
            return $.parent.dup-handler( :ip( $!first-addr ), :$!prefix-len );
        }
        when ip {
            return $.parent.dup-handler( :ip( $!first-addr ) );
        }
    }
    die "Unknown IP form '$!form'";
}

method next {
    return Nil if $!addr >= $!last-addr;
    $.parent.dup.inc
}

method prev {
    return Nil if $!addr <= $!first-addr;
    $.parent.dup.dec
}

method next-network {
    return Nil unless $!form == cidr;

    $!parent.dup-handler( :ip( self.network.int-first-ip + self.size ), :prefix-len( $!prefix-len ) )
}

method prev-network {
    return Nil unless $!form == cidr;

    $!parent.dup-handler( :ip( self.network.int-first-ip - self.size ), :prefix-len( $!prefix-len ) )
}

# TODO Check for IP range start/end
method next-range {
    return Nil unless $!form == range;

    my $size = self.size;
    $!parent.dup-handler( :first( $!first-addr + $size ), :last( $!last-addr + $size ) );
}

method prev-range {
    return Nil unless $!form == range;

    my $size = self.size;
    $!parent.dup-handler( :first( $!first-addr - $size ), :last( $!last-addr - $size ) );
}

proto method to-int (|) { * }
multi method to-int ( @ntets where { $_.elems ≤ self.n-tets } --> Int ) { 
    my Int $int-ip = 0;
    $int-ip = $int-ip * $!n-tet-size + $_ for @ntets; 
    self.bitcap( $int-ip ) 
}
multi method to-int ( *@ntets where { $_.elems ≤ self.n-tets } --> Int ) { samewith( @ntets ) }

method to-n-tets ( Int:D $addr is copy = $!addr --> List ) {
    my @tets;
    my $tet-bits = ( self.addr-len / self.n-tets ).Int;
    for (self.n-tets - 1)...0 -> $i {
        @tets[ $i ] = self.bitcap( $addr, $tet-bits );
        $addr +>= $tet-bits;
    }
    @tets.List;
}

method info {
    for self.ip-classes -> $info {
        if self.overlaps( $info<net> ) {
            if $info<net>.contains( self ) {
                return $info<info>;
            }
            return { scope => undetermined, description => "range overlaps with but not contained by a reserved range" }
        }
    }

    return { scope => public, description => "public IP" }
}

method Str { 
    #note ".Str";
    given $!form {
        when ip { return self.int2str( $!addr ); }
        when cidr { return self.prefix }
        when range {
            return self.int2str( $!first-addr ) ~ "-" ~ self.int2str( $!last-addr );
        }
    }
    die "Unknown IP form '$!form'";
}

method !bits2mask ( Int $bits ) {
    %bitcap-mask{ $!addr-bits } +& +^ (2**($!addr-bits - $bits) - 1) 
}

method !pfx2mask( Int $len ) { # Subject for is cached trait
    state %pfx2mask; # Prefix length into network mask

    unless %pfx2mask{ $!addr-bits } {
        %pfx2mask{ $!addr-bits } = %( 
            (0..$!addr-bits).map: {
                $_ => self!bits2mask( $_ )
            } 
        );
    }

    %pfx2mask{ $!addr-bits }{ $len }
}

method !mask2pfx ( Int $mask ) {
    state %mask2pfx;

    unless %mask2pfx{ $!addr-bits } {
        %mask2pfx{ $!addr-bits } = %(
            (0..$!addr-bits).map: {
                self!bits2mask( $_ ) => $_
            } 
        );
    }

    %mask2pfx{ $!addr-bits }{ $mask }
}

method !reset {
    $!addr = $!mask = $!prefix-len = $!wildcard = $!first-addr = $!last-addr = 0;
    $!form = unknown;
}

method !recalc( @src ) {
    given @src[0] {

        self!reset;
        $!form = $_;

        when ip {
            #note "SRC VALUE:", $src.value;
            $!addr = @src[1]<ip>;
            $!prefix-len = $!addr-bits;
            self!recalc-mask;
            self!recalc-wildcard;
            self!recalc-range;
        }

        when range {
            $!addr = $!first-addr = self.bitcap( @src[1]<first> );
            $!last-addr = self.bitcap( @src[1]<last> );
        }

        when cidr {
            #note "SRC:", $src;
            $!addr = @src[1]<ip>;
            $!prefix-len = self.bitcap( @src[1]<prefix-len> );
            self!recalc-mask;
            self!recalc-wildcard;
            self!recalc-range;
        }

        default {
            die "Possible internal failure: unknown IP form $_";
        }
    }
}

method !recalc-mask {
    $!mask = self!pfx2mask( $!prefix-len );
}

method !recalc-wildcard {
    $!wildcard = +^ self.bitcap( $!mask );
}

method !recalc-prefix-len { 
    $!prefix-len = self!mask2pfx( $!mask );
}

method !recalc-range {
    $!first-addr = self.bitcap( $!addr +& $!mask );
    $!last-addr = self.bitcap( $!first-addr + $!wildcard );
}

=begin pod

=AUTHOR  Vadim Belman <vrurg@cpan.org>

=head1 SEE ALSO

IP::Addr, IP::Addr::v4, IP::Addr::v6

=end pod

# vim: ft=perl6 et sw=4
