use v6;

#
# Copyright © 2018-2019 Joelle Maslak
# All Rights Reserved - See License
#

unit module Net::BGP::IP:ver<0.1.1>:auth<cpan:JMASLAK>;

# IPv4
#
#

our @octet = ^256;
our subset ipv4 of Str where / ^ @octet**4 % '.' $ /;
our subset ipv4_int of UInt where ^(2³²);
our subset ipv4_len of UInt where ^33;

# use NativeCall;
# sub inet_aton(Str $str is encoded('utf8'), uint32 $addr is rw -->uint32) is native {*};
# sub ntohl(uint32 $net -->uint32) is native {*};

# XXX - Regexes are way slow.
# our sub ipv4-to-int(ipv4:D $ip -->uint32) is export {
our sub ipv4-to-int(Str:D $ip -->uint32) is export {
    # my uint32 $result = 0;
    # my $ret = inet_aton($ip, $result);
    # die("Could not convert name to IP") if $ret == 0;
    # return ntohl($result);
    # 
    my uint32 $ipval = 0;
    for $ip.split('.') -> Int(Str) $part {
        $ipval = $ipval +< 8 + $part;
    }

    return $ipval;
}

# XXX - Regexes are way slow.
# our sub ipv4-to-buf8(Str:D $ip -->buf8:D) is export {
our sub ipv4-to-buf8(Str:D $ip -->buf8:D) is export {
    return buf8.new( $ip.split('.')».Int );
}

our sub int-to-ipv4(ipv4_int:D $i -->Str:D) is export {
    my uint32 $ip = $i;
    return join('.', $ip +> 24, $ip +> 16 +& 255, $ip +> 8 +& 255, $ip +& 255);
}

our sub buf8-to-ipv4(*@parts -->Str:D) is export {
    if @parts.elems ≠ 4 { die("Must pass 4 parts - you passed { @parts.elems }") }
    if @parts.first({ $^a !~~ ^256 }).defined { die("Invalid IP address") }
    return join('.', @parts);
}

# IPv6
#
#

# Take from Rosetacode
#   https://rosettacode.org/wiki/Parse_an_IP_Address#Perl_6
grammar IPv6 {
    token TOP { ^ <IPv6Addr> $ }

    token IPv6Addr {
        | <h16> +% ':' <?{ $<h16> == 8}>
            { @*by16 = @$<h16> }

        | [ (<h16>) +% ':']? '::' [ (<h16>) +% ':' ]? <?{ @$0 + @$1 ≤ 8 }>
            { @*by16 = |@$0, |('0' xx 8 - (@$0 + @$1)), |@$1; }
    }

    token h16 { (<:hexdigit>+) <?{ @$0 ≤ 4 }> }
}

# Need to define @*by16 to use the IPv6.parse() routine
our subset ipv6 of Str where { my @*by16; IPv6.parse($_) };
our subset ipv6_int of UInt where * < 2¹²⁸;

our sub ipv6-to-int(ipv6:D $ip -->ipv6_int) is export {
    my @*by16;
    IPv6.parse($ip);
    return :16(@*by16.map({:16(~$_)})».fmt("%04x").join);
}

our sub ipv6-to-buf8(
    ipv6:D $ip,
    Int :$bits? = 128
    -->buf8:D
) is export {
    my $bytes = (($bits + 7) / 8).Int;
    my @storage;

    my $int = ipv6-to-int($ip);
    $int = $int +> (128-$bits) +< (128-$bits);

    for ^16 -> $byte {
        @storage.unshift($int +& 255);
        $int = $int +> 8;
    }

    return buf8.new( @storage[^$bytes] );
}

our sub buf8-to-ipv6(
    buf8:D $buf,
    Int :$bits? = 128
    --> ipv6:D
) is export {
    my $bytes = (($bits + 7) / 8).Int;
    if $buf.bytes ≠ $bytes {
        die("buf8-to-ipv6 called with wrong length buffer ($bytes ≠ {$buf.bytes})");
    }

    my $int = 0;
    for ^16 -> $byte {
        $int  = $int +< 8;
        $int += $buf[$byte] unless $byte ≥ $bytes;
    }
    $int = $int +> (128-$bits) +< (128-$bits);

    return int-to-ipv6($int);
}

our sub int-to-ipv6(ipv6_int:D $ip is copy -->Str:D) is export {
    if $ip == 0 { return '::' }      # Special case

    my @parts;
    for ^8 -> $i {
        my uint16 $part = $ip +& 0xffff;
        $ip = $ip +> 16;
        @parts.unshift: $part;
    }

    my $best-run;
    my $best-length = 0;
    my $run-start;
    my $run-length = 0;
    for ^8 -> $i {
        if @parts[$i] ≠ 0 {
            $run-length = 0;
        } else {
            $run-start = $i unless $run-length > 0;
            $run-length++;

            if $run-length > $best-length {
                $best-run    = $run-start;
                $best-length = $run-length;
            }
        }
    }

    my $str = '';
    for ^8 -> $i {
        if $best-run.defined and $i ≥ $best-run and $i < ($best-run + $best-length) {
            $str ~= ':' if $i == $best-run;
        } else {
            if $i ≠ 7 {
                $str ~= @parts[$i].fmt("%x") ~ ':';
            } else {
                $str ~= @parts[$i].fmt("%x");
            }
        }
    }

    return $str;
}

our sub ipv6-expand(ipv6:D $ip -->ipv6:D) is export {
    my @*by16;
    IPv6.parse($ip);
    return @*by16.map({:16(~$_)})».fmt("%04x").join(':');
}

our sub ipv6-compact(ipv6:D $ip -->ipv6:D) is export {
    my @*by16;
    IPv6.parse($ip);
    my $compact = @*by16.map({:16(~$_)})».fmt("%x").join(':');

    # This looks weird - basically we try matching from most to
    # least.
    if $compact ~~ s/^ '0:0:0:0:0:0:0:0' $/::/ {
    } elsif $compact ~~ s/ [ ^ || ':' ] '0:0:0:0:0:0:0' [ ':' | $ ] /::/ {
    } elsif $compact ~~ s/ [ ^ || ':' ] '0:0:0:0:0:0' [ ':' | $ ] /::/ {
    } elsif $compact ~~ s/ [ ^ || ':' ] '0:0:0:0:0' [ ':' | $ ] /::/ {
    } elsif $compact ~~ s/ [ ^ || ':' ] '0:0:0:0' [ ':' | $ ] /::/ {
    } elsif $compact ~~ s/ [ ^ || ':' ] '0:0:0' [ ':' | $ ] /::/ {
    } elsif $compact ~~ s/ [ ^ || ':' ] '0:0' [ ':' | $ ] /::/ {
    } elsif $compact ~~ s/ [ ^ || ':' ] '0' [ ':' | $ ] /::/ {
    }

    return $compact;
}

our subset ipv4_as_ipv6 of Str where {
    $_.fc.starts-with("::ffff:") and m:i/ ^ '::ffff:' @octet**4 % '.' $ /
};

sub ip-cannonical(Str:D $ip -->Str) is export {
    state %cached;

    return $ip unless $ip.contains(':');
    
    return %cached{$ip} //= ipv6-cannonical($ip);
}

multi ipv6-cannonical(ipv6:D $ip -->Str) {
    state %cached;
    return %cached{$ip} //= ipv6-compact($ip);
}
multi ipv6-cannonical(ipv4_as_ipv6:D $ip -->Str) {
    state %cached;
    return %cached{$ip} //= (S:i/^ '::ffff:' // given $ip);
}

our proto ip-valid(Str:D $ip -->Bool) is export {*};

multi ip-valid(ipv6:D $ip         -->Bool) { True }
multi ip-valid(ipv4:D $ip         -->Bool) { True }
multi ip-valid(ipv4_as_ipv6:D $ip -->Bool) { True }
multi ip-valid(Str:D $ip          -->Bool) { False }


=begin pod

=head1 NAME

Net::BGP::IP - IP Address Handling Functionality

=head1 SYNOPSIS

=head2 IPv4

  use Net::BGP::IP;

  my $ip = int-to-ipv4(1000);         # Converts 1000 to an IPv4 string
  my $int = ipv4-to-int('192.0.2.4'); # Converts to an integer
  
  # Returns 192.0.2.1
  my $cannonical = ip-cannonical('192.0.2.'1);
  my $cannonical = ip-cannonical('::ffff:192.0.2.'1);

=head2 IPv6    

  use Net::BGP::IP;

  # Returns 2001:db8::1
  my $ip = int-to-ipv6(42540766411282592856903984951653826561); # 2001:db8::1

  # Returns the integer value of 2001:db8::1
  my $int = ipv6-to-int('2001:db8::1');

  # Will return: 2001:0db8:0000:0000:0000:0000:0000:0000
  my $expanded = ipv6-expand('2001:db8::1');

  # Will return 2001:db8::1
  my $compact = ipv6-compact('2001:0db8:0:000:0::01');

  # Returns 2001:db8::1
  my $cannonical = ip-cannonical('2001:0db8:0::0:1');

=head1 SUBROUTINES

=head2 buf8-to-ipv4

Takes a buffer (or any other list of numbers) 4 elements long and, assuming
network ordering, returns an IPv4 address.

=head2 int-to-ipv4

Converts an integer into a string representation of an IPv4 address.

=head2 ipv4-to-int

Converts an IPv4 string into an integer.

=head2 ipv4-to-buf8

Converts an IPv4 string into a buf8 object (in network byte order).

=head2 int-to-ipv6

Converts an integer into a string representation of an IPv6 address.

=head2 ipv6-to-int

Converts an IPv6 string into an integer.

=head2 ipv6-to-buf8

Converts an IPv6 string into a buf8 object (in network byte order).

=head2 ipv6-expand

Expands an IPv6 address by expanding "::" and adding leading zeros.

=head2 ipv6-compact

Produces the shortest possible string representation of an IPv6 address.

=head2 ip-cannonical

Returns the shortest possible string representation of an IPv4 or IPv6
address.

=head2 ip-valid

Returns true if the IP address is a valid IPv4 or IPv6 address.

=head1 IPv4 

=head1 AUTHOR

Joelle Maslak <jmaslak@antelope.net>

=head1 COPYRIGHT AND LICENSE

Copyright © 2018-2019 Joelle Maslak

This library is free software; you can redistribute it and/or modify it under the Artisitc License 2.0.

=end pod

