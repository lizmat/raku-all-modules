#! /usr/bin/env false

=begin pod

=NAME    IP::Addr - dealing with IPv4/IPv6 addresses

=head1 SYNOPSIS

    my $cidr = IP::Addr.new( "192.0.2.2/27" );
    say $cidr;
    say $cidr.ip;
    for $cidr.network.each -> $ip {
        say $ip;
    }

    my $cidr6 = IP::Addr.new( "600d::f00d/123" );
    say $cidr6;
    say $cidr6.ip;

=head1 DESCRIPTION

This module provides functionality for working with IPv4/IPv6 addresses.

=head2 Module Structure

The main interface is provided by C<IP::Addr> class. Typical class usage is demonstrated in the synopsis. The class is
a frontend which tries to determine version of the IP address provided to its constructor and creates corresponding
handler object available on its C<handler> attribute. All methods of the handler are available on C<IP::Addr> object via
C<handles> trait.

For example, for an arbitrary C<$ip> object of the class C<$ip.ip> call is actually same as calling C<$ip.handler.ip>.
Method C<ip> is a universal one for both v4 and v6 addresses and therefore it is not necessary to care about what exact
kind of object we're currently dealing with.

Similarly, version-dependant methods are available too but only when corresponding handler is active. For example:

    say IP::Addr.new( "192.0.2.2/27" ).broadcast;

is a valid call; while

    say IP::Addr.new( "2001:db8::/123" ).broadcast;

will fail with "no method" exception because C<broadcast> is not available for IPv6 addresses.

=head2 Glossary

=head3 Address forms

Besides of its version each IP address has one more characteristic property: form. It is defined by handler's attribute
of the same name: C<$!form>. Particular forms are defined by IP-FORM enum defined in C<IP::Addr::Common>:

=begin item
I<ip>

Simple IP address. It has prefix length of 32 bits.
=end item

=begin item 
I<cidr>

CIDR form is an IP address with I<prefix> defined.

    192.0.2.3/24
    192.0.2.3/255.255.255.0
    2001::/64
=end item

=begin item
I<range>

A range is defined by its first and last IP addresses. It has a I<selected> or I<current> IP address which could be
changed as a result of increase, decrease, or iteration operations.

    192.0.2.3-192.0.2.20
    2001::1-2001::1f
=end item

=head3 Ranged forms

CIDR and ranges are I<ranged forms> contrary to a single IP form.

=head3 N-tets

As it is known IP addresses are represented by groups of integers called I<octets> for IPv4 and I<hextets> for IPv6
(there are variantions but I chose these). I<N-tets> is used as a general term for both of them.

=head1 METHODS

=head2 Constructor

Class constructor C<new> simply re-dispatches its arguments to method C<set>.

=head2 C<set>

=begin item
I<C<$ip.set( Str $source )> / C<$ip.set( Str :$source! )>>

C<$source> is a string representation of an IP address in either plain or CIDR notation, or of a range of addresses in
a form I< <first ip>-<last ip> >. Formats of valid IP addresses are defined by corresponding standards.
=end item

=begin item
I<C<$ip.set( [ :v4 | :v6 ], *%params )>>

Creates a handler object of specified version of handler (v4 or v6) by passing named C<%params> to its constructor.

For example, the following statement:

    $ip.set( :v4, ip => 3221225986, prefix-len => 24 )

Is equivalent to:

    $ip.set( "192.0.2.2/24" )

B<Note:> all calls to C<set> method result in creation of a new handler object. I.e.:

    my $old-handler = $ip.handler;
    $ip.set( ... );
    say $old-handler === $ip.handler; # False
=end item

=head2 C<Str>

Returns a valid string representation of the IP object.

=head2 C<gist>

Same as C<Str> method.

=head2 C<each>

Returns an iterable object which would iterate over IPs contained in the current object starting with selected address
(i.e.  the one returned by C<ip> method). For ranged forms to iterate over the whole range (from the C<first-ip> to the
C<last-ip>) use of method C<first> is recommended:

        .say for IP::Addr.new( "192.0.2.3/29" ).each;           # 192.0.2.3/29\n192.0.2.4/29 ...
        .say for IP::Addr.new( "192.0.2.3/29" ).first.each;     # 192.0.2.0/29\n192.0.2.1/29 ...

=head2 C<Supply>

Similar to C<each> method but returns a C<Supply> object. Same rule about starting with selected IP and use of C<first>
method apply.

=head1 HANDLER METHODS

This sections documents methods common for both IPv4 and IPv6 handlers.

=head2 Notes

For all methods accepting another IP address as a parameter and where descriptions has a statement I<"same version
only"> C<X::IPAddr::TypeCheck> exception would be thrown if object with a handler of different version is passed.

Address method parameters could either be C<IP::Addr> instances or string representations.

=head2 C<set>

Configures the handler object.

B<Note> In the following subsection C<$handler> notation is used instead of C<$ip.handler>.

=begin item
I<C<$handler.set( Str:D $source )> / C<$handler.set( Str:D :$source! )>>

Handler attributes are set by parsing a string representation of IP address.
=end item

=begin item
I<C<$handler.set( Int:D :$ip!, Int:D :$!prefix-len )>>

Configures handler object as I<CIDR> form.
=end item

=begin item
I<C<$handler.set( Int:D :$first!, Int:D :$!last, Int :$ip? )>>

Configures handler object as I<range> form. Optional named parameter C<:ip> defines selected IP within range (i.e. the
one returned by C<ip> method). If omitted then range initial selected IP is its first address.
=end item

=begin item
I<C<$handler.set( Int:D $ip! )>>

Configures a single IP form.
=end item

=begin item
I<C<$handler.set( Int:D @n-tets )>>

Configures a single IP form from integer octets for IPv4 or hextets for IPv6. Number of elements in @n-tets array is
defined by the method of the same name.
=end item

=head2 C<addr-len>

Returns number of bits for correponding IP version (I<32> for IPv4 and I<128> for IPv6).

=head2 C<n-tets>

Returns number of n-tets for the current handler (I<4> for IPv4 and I<8> for IPv6).

=head2 C<version>

Returns integer version of the IP object (I<4> or I<6>).

=head2 C<ip-classes>

Returns list of hashes of reserved IP ranges. Each hash has two keys:

=begin item
I<net>

C<IP::Addr> object representing the reserved range.
=end item

=begin item
I<info>

Another hash containing information about the scope of the reserved range in very brief text description:

=begin item
I<scope>

Scopes are defined by C<SCOPE> enum in C<IP::Addr::Common>. Currently the following scopes are known:

=item C<undetermined>
=item C<mpublic>
=item C<software>
=item C<private>
=item C<host>
=item C<subnet>
=item C<documentation>
=item C<internet>
=item C<routing>
=item C<link>

Of those C<routing> and C<link> are specific to IPv6. C<public> isn't officially recognized but used to represent
anything not been reserved. C<undetermined> is also a special value to be returned if a requested range of IP addresses
overlaps with a reserved range but isn't fully contained in it.
=end item

=begin item
I<description>

Textual information about the reserved block.
=end item
=end item

=head2 C<ip>

Returns a new C<IP::Addr> object representing just an IP address of the current C<IP::Addr> object.

    my $ip = IP::Addr.new( "192.0.2.3/24" );
    say $ip;            # 192.0.2.3/24
    say $ip.ip;         # 192.0.2.3
    say $ip.ip.WHO;     # IP::Addr

=head2 C<prefix>

Returns CIDR representation of any form of IP address. For example:

    say IP::Addr.new( "192.0.2.3" ).prefix;     # 192.0.2.3/32

For IPv4 handler additional named parameter C<:mask> can be used to use network mask instead of prefix length:

    say IP::Addr.new( "192.0.2.3/24" ).prefix( :mask );     # 192.0.2.3/255.255.255.0

=head2 C<first-ip>

C<IP::Addr> object for the first IP address in the range. For single IP will be the same as C<ip> method.

=head2 C<last-ip>

C<IP::Addr> object for the last IP address in the range. For single IP will be the same as C<ip> method.

=head2 C<network>

C<IP::Addr> object of the network current IP object belongs to. Makes real sense for CIDR form only though can be used
with any other form too.

=head2 C<mask>

Returns string representation of the current IP object mask. Doesn't make much sense for IPv6 addresses because there
is officially no such thing for them.

=head2 C<wildcard>

Returns string representation of current IP object wildcard. Doesn't make much sense for IPv6 addresses because there
is officially no such thing for them.

=head2 C<size> 

Returns number of IP addresses contained in the current C<IP::Addr> object. For example:

    say IP::Addr.new( "192.0.0.0/13" ).size;            # 524288
    say IP::Addr.new( "192.0.2.3-192.0.2.23" );         # 21

=head2 C<int-ip>

Returns integer value of the IP address.

=head2 C<int-first-ip>

Returns integer value of the first IP address in the current IP object.

=head2 C<int-last-ip>

Returns integer value of the last IP address in the current IP object.

=head2 C<int-mask>

Returns integer value of current IP object mask. Though not defined as such for IPv6 addresses but could be useful in
some address arithmetics.

=head2 C<int-wildcard>

Returns integer value of current IP object wildcard. Though not defined as such for IPv6 addresses but could be useful
in some address arithmetics.

=head2 C<inc> / C<succ>

Increments IP address by I<1>. For ranged IP forms result of this operation won't be greater than the last IP of the
range:

        my $ip = IP::Addr.new( "192.0.2.255/24" );
        say $ip.inc;                # 192.0.2.255/24

Rerturns current C<IP::Addr> object.

=head2 C<dec> / C<pred>

Decrements IP address by I<1>. For ranged IP forms result of this operation won't be less than the first IP of the
range:

        my $ip = IP::Addr.new( "192.0.2.0/24" );
        say $ip.dec;                # 192.0.2.0/24

Returns current C<IP::Addr> object.

=head2 C<add( Int:D $count )>

Shifts IP of the current object by C<$count> positions higher. C<$count> could be negative. For ranged IP form the
result of the operation won't leave the range boundaries:

    my $ip = IP::Addr.new( "192.0.2.255/24" );
    say $ip.add( 10 );              # 192.0.2.255/24
    say $ip.add( -300 );            # 192.0.2.0/24

Returns current C<IP::Addr> object.

=head2 C<eq( $addr )>

Same version only.

Returns I<True> if current object is equal to C<$addr>.

=head2 C<lt( $addr )>

Same version only.

Returns true if the current object is less than C<$addr>.

=head2 C<gt( $addr )>

Same version only.

Returns true if the current object is greater than C<$addr>

=head2 C<cmp( $addr )>

Same version only.

Returns one of three C<Order> values: C<Less>, C<Same>, or C<More>. For ranges comparison is performed by the selected
IP.

=head2 C<contains( $addr )>

Same version only.

Returns I<True> if current object contains C<$addr>. Wether the C<$addr> object is the same (e.g. C<eq> method would
return I<True>) then it is also considered as contained.

=head2 C<overlaps( $addr )>

Same version only.

Returns I<True> if the current object and C<$addr> have at least one common IP address. Useful for starting iteration:

=head2 C<first>

Returns a new C<IP::Addr> object whose IP address is the first IP of the current object. Useful for starting iteration.

    my $ip = IP::Addr.new( "192.0.2.12/24" );
    for $ip.first.each { say $_ }       # 192.0.2.0\n192.0.2.1\n...

See C<each> method.

=head2 C<next>

Returns a new C<IP::Addr> object successive to the current object or I<Nil> if current is the last IP of the range.

=head2 C<prev>

Returns a new C<IP::Addr> object preceding the current object or I<Nil> if current is the first IP of the range.

=head2 C<next-network>

Returns a new C<IP::Addr> object containing network successive to the network of the current object. Valid for CIDR
form only. Flips over begining/end of IP range:

    $ip = IP::Addr.new( "255.255.255.13/24" );
    say $ip.next-network;               # 0.0.0.0/24

=head2 C<prev-network>

Returns a new C<IP::Addr> object containing network preceding the network of the current object. Valid for CIDR form
only. Flips over the begining of IP range:

    $ip = IP::Addr.new( "0.0.0.2/24" );
    say $ip.prev-network;               # 255.255.255.0/24

=head2 C<next-range>

Returns a new C<IP::Addr> object containing range of the same length successive to the current object. Valid for range
form only.

=head2 C<prev-range>

Returns a new C<IP::Addr> object containing range of the same length preceding the current object. Valid for range form
only.

=head2 C<to-int( @n-tets )>

Converts an array of n-tets to integer value corresponding to the current handler's IP version.

=head2 C<to-n-tets( Int:D $addr )>

Splits integer represnation of IP address into n-tets corresponding to the current handler's IP version.

=head2 C<info>

Returns a hash with information about the current IP object. The hash contains two keys: C<scope> and C<description>.
See C<ip-classes> method for more information.

=head2 C<Str>

Stringifies current IP object with regard to its form.

=head1 OPERATORS

For all supported operators where both operands are addresses at least one of them has to be a C<IP::Addr> object. The
other one could be a string representation of an address.

=head2 C<prefix/postfix ++> and C<prefix/postfix -->

Standard Perl6 operatios working by calling C<succ>/C<pred> methods on C<IP::Addr> object.

=head2 C<infix + ( $addr, $int )>

Adds an integer value to the address. The resulting address will never get out of network/range boundaries for objects
of corresponding forms. A new C<IP::Addr> object is returned.

    $ip2 = $ip1 + 3;

=head2 C<infix - ( $addr, $int )>

Deducts an integer value from the address. The resulting address will never get out of network/range boundaries for objects
of corresponding forms. A new C<IP::Addr> object is returned.

    $ip2 = $ip1 - 3;

=head2 C<infix cmp ( $addr1, $addr2 )>

Compares two IP addresses.

    given $ip1 cmp $ip2 {
        when Less { say "smaller" }
        when Same { say "same" }
        when More { say "bigger" }
    }

=head2 C<infix eqv / infix == ( $addr1, $addr2 )>

Checks if two addresses are equal. See handler's C<eq> method.

=head2 C«infix < ( $addr1, $addr2 )»

I<True> if C<$addr1> is less than C<$addr2>. See handler's C<lt> method.

=head2 C«infix <= / infix ≤ ( $addr1, $addr2 )»

I<True> if C<$addr1> is less than or equal to C<$addr2>.

=head2 C«infix > ( $addr1, $addr2 )»

I<True> if C<$addr1> is greater than C<$addr2>. See handler's C<gt> method.

=head2 C«infix >= / infix ≥ ( $addr1, $addr2 )»

I<True> C<$addr1> greater than or equal to C<$addr2>.

=head2 C<infix (cont) / infix ⊇ ( $addr1, $addr2 )>

I<True> if C<$addr1> object contains C<$addr2>. See handler's C<contains> method.

=head2 C<infix ⊆ ( $addr1, $addr2 )>

I<True> if C<$addr1> is contained by C<$addr2>.

=end pod

use v6.c;

unit class IP::Addr:ver<0.0.1>;

use IP::Addr::Handler;
use IP::Addr::v4;
use IP::Addr::v6;

has IP::Addr::Handler $.handler handles **;

proto method new (|) { * }
multi method new ( IP::Addr::Handler:D :$handler! ) {
    self.bless( :$handler )
}
multi method new ( |args ) {
    self.bless.set( |args )
}

multi submethod TWEAK ( IP::Addr::Handler:D :$!handler ) {
    #note "TWEAK WITH handler";
    $!handler.parent = self;
}
multi submethod TWEAK () { }

proto method set (|) { {*}; self }

multi method set( Str:D $source, *%params ) { samewith( :$source, |%params ) }

multi method set( Str:D :$source!, *%params ) {
    if is-ipv4( $source ) {
        #note "Creating IPv4 hander";
        $!handler = IP::Addr::v4.new( :$source, :parent( self ), |%params );
    }
    elsif is-ipv6( $source ) {
        #note "Creating IPv6 hander";
        $!handler = IP::Addr::v6.new( :$source, :parent( self ), |%params );
    }
    else {
        die "Unknown address format";
    }
}

multi method set( :$v4?, :$v6?, *%params ) {
    if $v4 {
        $!handler = IP::Addr::v4.new( :parent( self ), |%params );
    }
    elsif $v6 {
        $!handler = IP::Addr::v6.new( :parent( self ), |%params );
    }
    else {
        die "IP version is not specified for Int address; perhaps :v4 or :v6 was forgotten";
    }
}

method Str { $!handler.Str }
multi method gist ( ::?CLASS:D: --> Str) { self.handler.Str }
multi method gist ( ::?CLASS:U: ) { nextsame }

multi infix:<+> ( IP::Addr:D $ip, Int:D $count ) is export {
    $ip.dup.add( $count )
}

multi infix:<+> ( Int:D $count, IP::Addr:D $ip ) is export {
    $ip.dup.add( $count )
}

multi infix:<-> ( IP::Addr:D $ip, Int:D $count ) is export {
    $ip.dup.add( -$count )
}

multi infix:<cmp> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.cmp( $b )
}

multi infix:<cmp> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.cmp( $b )
}

multi infix:<cmp> ( Str:D $a, IP::Addr:D $b ) is export {
    $b.dup-handler( $a ).cmp( $b )
}

multi infix:<eqv> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.eq( $b )
}

multi infix:<eqv> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.eq( $b )
}

multi infix:<eqv> ( Str:D $a, IP::Addr:D $b ) is export {
    $b.dup-handler( $a ).eq( $b )
}

multi infix:<==> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.eq( $b )
}

multi infix:<==> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.eq( $b )
}

multi infix:<==> ( Str:D $a, IP::Addr:D $b ) is export {
    $b.dup-handler( $a ).eq( $b )
}

multi infix:<< < >> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.lt( $b )
}

multi infix:<< < >> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.lt( $b )
}

multi infix:<< < >> ( Str:D $a, IP::Addr:D $b ) is export {
    $b.dup-handler( $a ).lt( $b )
}

multi infix:<< <= >> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.lt( $b ) or $a.eq( $b )
}

multi infix:<< <= >> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.lt( $b ) or $a.eq( $b )
}

multi infix:<< <= >> ( Str:D $a, IP::Addr:D $b ) is export {
    my $ip-a = $b.dup-handler( $a );
    $ip-a.lt( $b ) or $ip-a.eq( $b )
}

multi infix:<< ≤ >> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.lt( $b ) or $a.eq( $b )
}

multi infix:<< ≤ >> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.lt( $b ) or $a.eq( $b )
}

multi infix:<< ≤ >> ( Str:D $a, IP::Addr:D $b ) is export {
    my $ip-a = $b.dup-handler( $a );
    $ip-a.lt( $b ) or $ip-a.eq( $b )
}

multi infix:<< > >> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.gt( $b )
}

multi infix:<< > >> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.gt( $b )
}

multi infix:<< > >> ( Str:D $a, IP::Addr:D $b ) is export {
    $b.dup-handler( $a ).gt( $b )
}

multi infix:<< >= >> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.gt( $b ) or $a.eq( $b )
}

multi infix:<< >= >> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.gt( $b ) or $a.eq( $b )
}

multi infix:<< >= >> ( Str:D $a, IP::Addr:D $b ) is export {
    my $ip-a = $b.dup-handler( $a );
    $ip-a.gt( $b ) or $ip-a.eq( $b )
}

multi infix:<< ≥ >> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.gt( $b ) or $a.eq( $b )
}

multi infix:<< ≥ >> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.gt( $b ) or $a.eq( $b )
}

multi infix:<< ≥ >> ( Str:D $a, IP::Addr:D $b ) is export {
    my $ip-a = $b.dup-handler( $a );
    $ip-a.gt( $b ) or $ip-a.eq( $b )
}

multi infix:<(cont)> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.contains( $b )
}

multi infix:<(cont)> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.contains( $b )
}

multi infix:<(cont)> ( Str:D $a, IP::Addr:D $b ) is export {
    $b.dup-handler( $a ).contains( $b )
}

multi infix:<⊇> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $a.contains( $b )
}

multi infix:<⊇> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.contains( $b )
}

multi infix:<⊇> ( Str:D $a, IP::Addr:D $b ) is export {
    $b.dup-handler( $a ).contains( $b )
}

multi infix:<⊆> ( IP::Addr:D $a, IP::Addr:D $b ) is export {
    $b.contains( $a )
}

multi infix:<⊆> ( IP::Addr:D $a, Str:D $b ) is export {
    $a.dup-handler( $b ).contains( $a )
}

multi infix:<⊆> ( Str:D $a, IP::Addr:D $b ) is export {
    $b.contains( $a )
}

proto method dup (|) {
    my $dup = {*};
    $dup.handler.parent = $dup;
    $dup
}

multi method dup {
    self.clone( :handler( $.handler.clone ) )
}

multi method dup ( :$handler! ) {
    self.clone( :$handler )
}

method dup-handler( |args ) {
    my $dup = self.clone( :handler( $.handler.clone ) );
    $dup.handler.parent = $dup;
    $dup.handler.set( |args );
    $dup
}

# ---- Iterable ----

my class IPIterable does Iterable {
    has $.ip;

    method iterator {
        my class IPIterator does Iterator {
            has $.ip is rw;

            method pull-one {
                return IterationEnd without $.ip;
                my $current = $.ip;
                $.ip = $.ip.next;
                $current
            }
        };
        IPIterator.new( :$!ip )
    }
}

method each {
    IPIterable.new( :ip( self ) )
}

method Supply {
    #my $ip = self.dup-handler( :first( $.handler.int-first-ip ), :last( $.handler.int-last-ip ) );
    my $ip = self.dup;
    supply {
        repeat {
            emit $ip;
        } while $ip = $ip.next;
    }
}

method first { $!handler.first }

method list ( --> List(Array) ) {
    my @list;
    for self.each -> $ip {
        @list.push: $ip;
    }
    @list;
}

=begin pod

=head1 CAVEATS

The author doesn't use IPv6 in his setups. All the functionality provided here is developed using information from
corresponding Wikipedia pages. Therefore, "here be dragons"©. Please, report back any issue encountered!

=AUTHOR  Vadim Belman <vrurg@cpan.org>

=end pod

# vim: ft=perl6 et sw=4
