use v6;
use Subsets::Common;

=begin pod

=head1 NAME

Net::IP::Parse - An IP type for Perl6.

=head1 DESCRIPTION

This library tries to fill a gap of a standard type for IP addresses that can
be used in programs and other libraries. Preferrably Perl6 would ship with
a default implementation for this common type, but until then, this is one
attempt at defining such a type.

For our purposes, an IP address is an array of bytes. For IPv4, there
are four bytes. For IPv6, sixteen. Perl6 only provides a byte type
for native interfaces, and this doesn't have adequate degradation in case
of errors, so I have opted to use my own `Subsets::Common` which defines
a `UInt8` subset that integrates nicely for common use.

This library parses common formats for IP address and creates a `UInt8`
array of the right size that is well-formed. That means values that are
bytes (between 0 and 255). This means you may be able to create instances
that are syntactically correct but are not applicable to real use given
some point of IP specification. This library does not concern itself
with determining if you instantiate a reserved or otherwise practically
useless IP address, I leave this to you to determine.

There is also support for a CIDR type which lets you stipulate network
ranges. 

The best set of examples for use can be found in the tests in `basic.t`
in the repository with this library.

IPv6 is complex. Please let me know what I have not properly supported.

=head1 SYNOPSIS

use v6;
use Subsets::Common; # required
use Net::IP::Parse;

my IP $ipv4_from_str = IP.new(addr=><1.2.3.4>);
my IP $ipv4_from_octets = IP.new(octets=>Array[UInt8].new(1,2,3,4));
say 'equal' if ($ipv4_from_str ip== $ipv4_from_octets);

my IP $ipv6_from_str = IP.new(addr=>'dfea:dfea:dfea:dfea:dfea:dfea:dfea:dfea');
my IP $ipv6_from_octets = IP.new(octets=>Array[UInt8].new(223,234,223,234,223,234,223,234,223,234,223,234,223,234,223,234));
say 'equal' if ($ipv6_from_str ip== $ipv6_from_octets);

my IP $ip1 = IP.new(addr=><2001:db8:a0b:12f0::1:1>);
say 'equal' if ($ip1.str eq '2001:db8:a0b:12f0:0:0:1:1');
my IP $ip2 = IP.new(addr=><2001:db8:a0b:12f0:0:0:1:1>);
say 'equal' if ($ip ip1== $ip2);

my IP $ip3 = IP.new(addr=><1:0:0:0:1:0:0:1>);
my $compressed = $ip3.compress_str;
say 'equal' if ($compressed eq '1::1:0:0:1');

my CIDR $cidr_ipv4 = CIDR.new(cidr=>'8.8.8.8/16');
my IP $ip4 = IP.new(addr=>'8.8.0.1');
say 'in' if ($ip4 in_cidr $cidr_ipv4);

my CIDR $cidr_ipv6 = CIDR.new(cidr=>'2001:db8::/32');
my IP $ip5 = IP.new(addr=>'2001:0db8:0000:0000:0000:0000:0000:0001');
say 'in' if ($ip5 in_cidr $cidr_ipv6);

=head1 AUTHOR 

Brad Clawsie (PAUSE:bradclawsie, email:brad@b7j0c.org) 

=head1 LICENSE This module is licensed under the BSD license, see: https://b7j0c.org/stuff/license.txt

=end pod

unit module Net::IP::Parse:auth<bradclawsie>:ver<0.0.2>;

my package EXPORT::DEFAULT {
    
    class X::Net::IP::Parse::Err is Exception {
        has $.input;
        method message() { 'error: ' ~ $.input; }
    }

    class AddressError is X::Net::IP::Parse::Err {}; # Backwards compatibility.
    
    subset IPVersion of Int where * == 4|6;

    my sub word_bytes(UInt16:D $word --> List:D[UInt8]) {
        return (($word +> 8) +& 0xff),($word +& 0xff); 
    }
    
    my sub bytes_word(UInt8:D $left_byte, UInt8:D $right_byte --> UInt16:D) {
        return (($left_byte +& 0xff ) +< 8) +| ($right_byte +& 0xff);
    }

    class IP {
        has UInt8 @.octets;
        has IPVersion $.version = Nil;
        has Str $.zone_id = Nil;
        
        multi submethod BUILD(Str:D :$addr) {
            if ($addr ~~ /\./) {
                my $matches = (rx|^(\d+).(\d+).(\d+).(\d+)$|).ACCEPTS: $addr;
                X::Net::IP::Parse::Err.new(input=>$addr).throw unless so $matches;
                my UInt8 @octets = $matches.list.map: {.UInt};
                self.BUILD(octets=>@octets);
            } elsif ($addr ~~ /\:/) {
                my ($octets_part,$zone_id_part) = $addr.split: '%',2;
                if $zone_id_part ~~ Str {
                    if $zone_id_part eq '' {
                        X::Net::IP::Parse::Err.new(input=>"malformed zone from $addr").throw;
                    }
                    $!zone_id := $zone_id_part
                }

                my UInt8 @bytes[16];
                @bytes[^16] = (loop { 0 });
                my (Str @left_words_strs, Str @right_words_strs);                
                given ($octets_part.comb: '::').Int {
                    when 0 {
                        @left_words_strs = $octets_part.split: ':';
                        if @left_words_strs.elems != 8 {
                            X::Net::IP::Parse::Err.new(input => "bad addr len: $addr").throw;
                        }
                    }
                    when 1 {
                        my ($left_words_str,$right_words_str) = $octets_part.split: '::', 2;
                        my sub f($s) { return ($s.split: ':').grep: {.chars > 0}; }
                        @left_words_strs = f $left_words_str;
                        @right_words_strs = f $right_words_str;
                        if @left_words_strs.elems + @right_words_strs.elems > 6 {
                            X::Net::IP::Parse::Err.new(input => "bad segment count: $addr").throw;
                        }
                    }
                    default { X::Net::IP::Parse::Err.new(input => "bad addr on split: $addr").throw; }
                }
                
                my ($i,$j) = (0,15);
                for @left_words_strs -> $word_str {
                    my UInt16 $word = $word_str.parse-base: 16;
                    (@bytes[$i++],@bytes[$i++]) = word_bytes $word;
                }
                for @right_words_strs.reverse -> $word_str {
                    my UInt16 $word = $word_str.parse-base: 16;
                    my ($l,$r) = word_bytes $word;
                    (@bytes[$j--],@bytes[$j--]) = ($r,$l);
                }                
                self.BUILD(octets=>@bytes)
            } else {
                X::Net::IP::Parse::Err.new(input=>"no version detected from $addr").throw;
            }
        }

        multi submethod BUILD(Array:D[UInt8] :$octets where $octets.elems == 4|16) {
            my $l := $octets.elems;
            my @a = Array[UInt8].new((0..^$l));
            for 0..^$l -> $j { @a[$j] = 0; }
            @!octets = @a;
            my $i = 0;
            for @($octets) -> $octet { @!octets[$i++] := $octet; }            
            $!version := $l == 4 ?? 4 !! 6;
        }
        
        method str(--> Str:D) {
            if $!version == 4 {
                return @!octets.join: '.';
            } else {
                return (@!octets.map: {sprintf("%x", bytes_word($^a,$^b))}).join: ':';
            }
        }

        method compress_str(--> Str:D) {
            if $!version == 4 {
                return self.str;
            } else {
                my ($i,$max_start,$max_end,$max_len,$start) = (0,0,0,0,-1);
                for @!octets -> $left_byte,$right_byte {
                    if $left_byte == 0 && $right_byte == 0 {
                        $start = $i if $start == -1;
                        my ($end,$len) = ($i,$i - $start);
                        ($max_start,$max_end,$max_len) = ($start,$end,$len) if $len > $max_len;
                    } else {
                        $start = -1;
                    }
                    $i++;
                }
                if $start != -1 {
                    my $len = 7 - $start;
                    ($max_start,$max_end,$max_len) = ($start,7,$len) if $len > $max_len;
                }

                my @print_words = @!octets.map: {sprintf("%x", bytes_word($^a,$^b))};
                if $max_len != 0 {                    
                    my ($pre,$post) = ('','');
                    $pre = @print_words[0..($max_start-1)].join: ':' if $max_start > 0;
                    $post = @print_words[($max_end+1)..7].join: ':' if $max_end < 8;
                    return $pre ~ '::' ~ $post;
                } else {
                    return @print_words.join: ':';
                }
            }
        }
    }
    
    my sub cmp(IP:D $lhs, IP:D $rhs --> Bool:D) {
        my $l := ($lhs.version == 4) ?? 4 !! 16;
        return $lhs.octets == $l && $rhs.octets == $l;
    }
    
    our sub infix:<< ip== >> (IP:D $lhs, IP:D $rhs --> Bool:D) {
        return cmp($lhs,$rhs) && so ($lhs.octets Z== $rhs.octets).all;
    }

    our sub infix:<< ip<= >> (IP:D $lhs, IP:D $rhs --> Bool:D) {
        return cmp($lhs,$rhs) && so ($lhs.octets Z<= $rhs.octets).all;
    }

    our sub infix:<< ip>= >> (IP:D $lhs, IP:D $rhs --> Bool:D) {
        return cmp($lhs,$rhs) && so ($lhs.octets Z>= $rhs.octets).all;
    }

    class CIDR {

        has UInt $.prefix;
        has IP $.addr;       
        has IP $.prefix_addr;
        has IP $.broadcast_addr;
        has IP $.network_addr;
        has IP $.wildcard_addr;
        
        multi submethod BUILD(Str:D :$cidr) {
            my Str @s = split('/',$cidr);
            unless (@s.elems == 2 && @s[0] ne '' && @s[1] ne '') {
                X::Net::IP::Parse::Err.new(input=>"bad cidr $cidr").throw;
            }
            my $prefix = (@s[1]).parse-base(10);
            X::Net::IP::Parse::Err.new(input=>"bad cidr $cidr").throw unless $prefix ~~ Int;
            self.BUILD(addr=>IP.new(addr=>@s[0]),prefix=>$prefix);
        }

        multi submethod BUILD(IP:D :$addr, UInt:D :$prefix) {
            my $octet_count = 4;
            my $max_prefix = 32;
            ($octet_count,$max_prefix) = (16,128) if $addr.version == 6;
            X::Net::IP::Parse::Err.new(input=>"prefix $prefix out of range").throw if $prefix > $max_prefix;

            # calculate mask
            my UInt8 @b[16];
            @b[^16] = (loop { 0 });
            my $div = $prefix div 8;
            for 0..^$div -> $i { @b[$i] = 255; }
            @b[$div] = 255 +^ (2**((($div + 1) * 8) - $prefix)-1);
            
            my UInt8 @mask_octets[$octet_count] = $addr.version == 4 ?? @b[0..3] !! @b;
            my UInt8 @wildcard_octets[$octet_count];
            my UInt8 @network_octets[$octet_count];
            my UInt8 @broadcast_octets[$octet_count];
            for 0..^$octet_count -> $i {
                @wildcard_octets[$i] = 255 - @mask_octets[$i];
                @network_octets[$i] = @mask_octets[$i] +& $addr.octets[$i];
                @broadcast_octets[$i] = @wildcard_octets[$i] +| $addr.octets[$i];
            }
            $!addr := $addr;
            $!prefix := $prefix;
            $!prefix_addr := IP.new(octets=>@mask_octets);
            $!network_addr := IP.new(octets=>@network_octets);
            $!wildcard_addr := IP.new(octets=>@wildcard_octets);
            $!broadcast_addr := IP.new(octets=>@broadcast_octets);
        }

        method str(--> Str:D) {
            return $!addr.str ~ '/' ~ $!prefix;
        }
    }

    our sub infix:<< in_cidr >> (IP:D $ip, CIDR:D $cidr where $ip.version == $cidr.addr.version --> Bool:D) {
        return $ip ip>= $cidr.network_addr && $ip ip<= $cidr.broadcast_addr;
    }
}
