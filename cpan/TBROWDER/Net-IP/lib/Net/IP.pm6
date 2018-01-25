unit module Net::IP:auth<github:tbrowder>;

use Number::More :bin2dec, :bin2hex,
                 :hex2bin, :token-binary;
use Text::More   :count-substrs;

# file: ALL-SUBS.md
# title: Subroutines Exported by the ':ALL' Tag

# export a debug var for users
our $DEBUG = False;
BEGIN {
    if %*ENV<MyMODULE_DEBUG> {
	$DEBUG = True;
    }
    else {
	$DEBUG = False;
    }
}

# define tokens for common regexes
my token domain           { :i ^ <[\w\d\-\.]>+ $ } # allowable chars, needs to be more constrained
my token ip-version       { ^ <[46]> $ }           # only two versions

#------------------------------------------------------------------------------
# Subroutine ip-reverse-domain
# Purpose : Reverse a domain name (only if FQDN, i.e., with dots)
# Params  : Domain name
# Returns : Reversed name
sub ip-reverse-domain(Str:D $dom is copy --> Str) is export(:ip-reverse-domain) {
    # check for validity
    if $dom ~~ &domain {
	return $dom unless $dom ~~ / '.' /;
	my @d = split '.', $dom;
	@d .= reverse;
	return join '.', @d;
    }

    return $dom;
} # ip-reverse-domain

#------------------------------------------------------------------------------
# Subroutine ip-reverse-address
# Purpose : Reverse an IP address, use dots for separators for all types
# Params  : IP address, IP version
# Returns : Reversed IP address on success, undef otherwise
sub ip-reverse-address(Str:D $ip is copy, UInt $ip-version where &ip-version --> Str) is export(:ip-reverse-address) {

    my $sep = $ip-version == 4 ?? '.' !! ':';

    my @fields;
    if $ip-version == 4 {
        $ip = ip-remove-leading-zeroes($ip, $ip-version);
        @fields = split $sep, $ip;
    }
    else {
        $ip = ip-expand-address($ip, 6);
        $ip ~~ s:g/ $sep //;
        @fields = $ip.comb;
    }

    @fields .= reverse;
    $ip = join '.', @fields;

    return $ip;
} # ip-reverse-address

#------------------------------------------------------------------------------
# Subroutine ip-bintoip
# Purpose : Transform a bit string into an IP address
# Params  : bit string, IP version
# Returns : IP address on success, undef otherwise
sub ip-bintoip(Str:D $binip is copy where &binary, UInt $ip-version where &ip-version --> Str) is export(:ip-bintoip) {

    # Define normal size for address
    my $len = ip-iplengths($ip-version);

    if $len < $binip.chars {
        warn "Invalid IP length ({$binip.chars}, should be $len) for binary IP $binip\n" if $DEBUG;
        return;
    }

    # Prepend 0s if address is less than normal size
    $binip = '0' x ($len - $binip.chars) ~ $binip;

    # IPv4
    if $ip-version == 4 {
	# split into individual bits
	my @c = $binip.comb;

	# convert each 8-bit octet to decimal and combine into the ip
	my $ip = '';
	#for 0, 8, 16, 24 -> $i {
	loop (my $i = 0; $i < 32; $i += 8) {
	    $ip ~= '.' if $i;
	    # get the next 8 bits
	    my $byte = join '', @c[$i..$i+7];
	    # convert next 8 bits to decimal
	    my $decimal = bin2dec($byte);
  	    $ip ~= $decimal;
	}
	return $ip;
    }

    # split into individual bits
    my @c = $binip.comb;

    # convert each 16-bit field to 4 hex chars and combine into the ip
    my $ip = '';
    #for 0, 16, 32, 48, 64, 80, 96, 112 -> $i {
    loop (my $i = 0; $i < 128; $i += 16) {
	$ip ~= ':' if $i;
	# get the next 16 bits
	my $half-word = join '', @c[$i..$i+15];
	# convert next 16 bits to hex
	my $hex = bin2hex($half-word, 4);
	$ip ~= $hex;
    }
    return $ip;
} # ip-bintoip

#------------------------------------------------------------------------------
# Subroutine ip-remove-leading-zeroes
# Purpose : Remove leading (unneeded) zeroes from octets or quads
# Params  : IP address
# Returns : IP address with no unneeded zeroes
sub ip-remove-leading-zeroes(Str:D $ip is copy, UInt $ip-version where &ip-version --> Str) is export(:ip-remove-leading-zeroes) {

    # IPv6 addresses must be expanded first
    $ip = ip-expand-address($ip, $ip-version) if $ip-version == 6;

    my $sep = $ip-version == 4 ?? '.' !! ':';

    my @quads = split $sep, $ip;
    # Remove leading 0s: 0034 -> 34; 0000 -> 0
    for @quads <-> $q {
	my @q = $q.comb;
	while +@q {
	    last if @q[0] ne '0';
	    shift @q;
	}
	if !+@q {
	    $q = '0';
	}
	else {
	    $q = join '', @q;
	}

	#$q = '0' if !+@q;
    }
    $ip = join $sep, @quads;

    return $ip;

} # ip-remove-leading-zeroes

#------------------------------------------------------------------------------
# Subroutine ip-compress-address
# Purpose : Compress an IPv6 address
# Params  : IP, IP version
# Returns : Compressed IP or undef (problem)
sub ip-compress-address(Str:D $ip is copy, UInt $ip-version where &ip-version --> Str) is export(:ip-compress-address) {

    # already compressed addresses must be expanded first
    $ip = ip-expand-address($ip, $ip-version) if $ip-version == 6;

    $ip = ip-remove-leading-zeroes($ip, $ip-version);

    if $ip-version == 4 {
        return $ip;
    }

    $ip = ip-remove-leading-zeroes($ip, $ip-version);

    # Find the longest :0:0: sequence
    my $long-seq;
    my $long-seq-idx;
    loop (my $i = 0; $i < 7; ++$i) {
       my $s = ':';
       $s ~= '0:' x $i;
       # search
       my $idx = index $ip, $s;
       if $idx.defined {
           if !$long-seq.defined {
               $long-seq     = $s.chars;
               $long-seq-idx = $idx;
           }
           elsif $s.chars > $long-seq {
               $long-seq     = $s.chars;
               $long-seq-idx = $idx;
           }
       }
    }

    # Replace longest sequence by '::'
    if $long-seq-idx.defined {
        # extract the two parts before and after the sequence
        my $ip0 = substr $ip, 0, $long-seq-idx + 1;
        my $ip1 = substr $ip, $long-seq-idx + $long-seq - 1;

        # then combine the two parts and we have the new, compressed ip
	$ip = $ip0 ~ $ip1;
    }

    return $ip;

} # ip-compress-address

#------------------------------------------------------------------------------
# Subroutine ip-iptobin
# Purpose : Transform an IP address into a bit string
# Params  : IP address, IP version
# Returns : bit string on success, undef otherwise
sub ip-iptobin(Str:D $ip is copy, UInt $ipversion --> Str) is export(:ip-iptobin) {

    # v4 -> return 32-bit array
    if $ipversion == 4 {
	my @octets = split '.', $ip;
	my $binip = '';
	for @octets -> $decimal {
	    my $s = sprintf "%08b", $decimal;
	    $binip ~= $s;
	}
	my $nbits = $binip.chars;
	if $nbits == 32 {
	    return $binip;
	}
	else {
	    warn "binip has $nbits bits, should be 32\n" if $DEBUG;
	    return;
	}
    }

    # expand to full size
    $ip = ip-expand-address($ip, 6);
    # Strip ':'
    $ip ~~ s:g/':'//;

    # Check hex size
    unless $ip.chars == 32 {
        warn "Bad IP address $ip\n" if $DEBUG;
        return;
    }


    # v6 -> return 128-bit array
    # split into individual hex chars
    $ip .= lc;
    my @c = $ip.comb;

    # convert each 4-bit hex digit to 4-bit binary, and combine into the ip
    my $binip = '';
    for @c -> $c {
	$binip ~= hex2bin($c, 4);
    }
    # Check binary size
    my $nbits = $binip.chars;
    if $nbits == 128 {
	return $binip;
    }
    else {
	warn "binip has $nbits bits, should be 128\n" if $DEBUG;
	return;
    }

} # ip-iptobin

#------------------------------------------------------------------------------
# Subroutine ip-iplengths
# Purpose : Get the length in bits of an IP from its version
# Params  : IP version
# Returns : Number of bits: 32, 128, 0 (don't know)
sub ip-iplengths(UInt:D $version --> UInt) is export(:ip-iplengths) {
    if $version == 4 {
        return 32;
    }
    elsif $version == 6 {
        return 128;
    }
    else {
        return 0; # unknown
    }

} # ip-iplengths

#------------------------------------------------------------------------------
# Subroutine ip-get-version
# Purpose : Get an IP version
# Params  : IP address
# Returns : 4, 6, 0 (don't know)
sub ip-get-version(Str:D $ip --> UInt) is export(:ip-get-version) {
    # If the address does not contain any ':', maybe it's IPv4
    return 4 if $ip !~~ /\:/ and ip-is-ipv4($ip);

    # Is it IPv6 ?
    return 6 if ip-is-ipv6($ip);

    return 0; # unknown

} # ip-get-version

#------------------------------------------------------------------------------
# Subroutine ip-expand-address
# Purpose : Expand an address from compact notation
# Params  : IP address, IP version
# Returns : expanded IP address or undef on failure
sub ip-expand-address(Str:D $ip is copy, UInt $ip-version where &ip-version --> Str) is export(:ip-expand-address) {

    # IPv4 : add .0 for missing quads
    if $ip-version == 4 {
        my @quads = split / '.' /, $ip;

        # check number of quads
        if +@quads > 4 {
            warn "Not a valid IPv4 address $ip\n" if $DEBUG;
            return;
        }
        my @clean_quads;
        for @quads.reverse -> $q {

            #check quad data
            if $q !~~ /^ \d ** 1..3 $/ {
                warn "Not a valid IPv4 address $ip\n" if $DEBUG;
                return;
            }

            # build clean ipv4

            #unshift (@clean_quads, $q + 1 - 1);
	    unshift @clean_quads, $q;

        }

	my $nq = +@clean_quads;
	while $nq < 4 {
	    push @clean_quads, '0';
	    ++$nq;
	}
        return (join '.', @clean_quads);
    }

    # IPv6

    # Keep track of ::
    my $num-double-colons = count-substrs($ip, '::');
    if $num-double-colons > 1 {
        warn "Too many :: in ip\n" if $DEBUG;
        return;
    }
    # mark the double colons
    $ip ~~ s/ '::' /:!:/;

    # IP as an array
    my @ip = split ':', $ip;

    # Number of actual octets
    my $num = +@ip;

    my $finalip = '';
    for @ip <-> $q {

        # Embedded IPv4
        if $q ~~ / '.' / {

            # Expand Ipv4 address
            # Convert into binary
            # Convert into hex
            # Keep the last two octets

	    die "fix this";

            $q = substr( ip-bintoip( ip-iptobin( ip-expand-address($q, 4), 4), 6), -9);

            # Has an error occured here ?
            return unless $q;

            # ++$num because we now have one more octet:
            # IPv4 address becomes two octets
            ++$num;
            next;
        }

        # Find the pattern
	if $q !~~ / '!' / {
	    $finalip ~= ':' if $finalip;
            # Add missing leading 0s
	    my $s = '0' x (4 - $q.chars);
	    $finalip ~= $s ~ $q;
	    next;
	}

	# how many zero fields do we need to fill?
	my $nfields = 9 - $num;
	for 1..$nfields {
	    $finalip ~= ':' if $finalip;
	    $finalip ~= '0000';
	}
    }

    return $finalip;

} # ip-expand-address

#------------------------------------------------------------------------------
# Subroutine ip-is-ipv4
# Purpose : Check if an IP address is version 4
# Params  : IP address
# Returns : True (yes) or False (no)
sub ip-is-ipv4(Str:D $ip is copy --> Bool) is export(:ip-is-ipv4) {
    # we don't use a constraint on the input here so we
    # can report specific problems for debugging

    unless $ip ~~ /^ <[\d\.]>+ $/ {
        warn "Invalid characters in IP '$ip'\n" if $DEBUG;
        return False;
    }

    if $ip ~~ /^ '.' / {
        warn "Invalid IP $ip - starts with a dot\n" if $DEBUG;
        return False;
    }

    if $ip ~~ / '.' $/ {
        warn "Invalid IP $ip - ends with a dot\n" if $DEBUG;
        return False;
    }

    # Single Numbers are considered to be IPv4
    if ($ip ~~ /^ (\d+) $/ and $0 < 256) { return True }

    # Count quads
    # IPv4 must have from 1 to 4 quads
    my $n = count-substrs($ip, '.');
    unless $n >= 0 and $n < 4 {
        warn "Invalid IP address $ip ($n dots found)\n" if $DEBUG > 1;
        return False;
    }
    warn "DEBUG: found $n dots\n" if $DEBUG;

    # Check for empty quads
    if $ip ~~ / '..' / {
        warn "Empty quad in IP address $ip\n" if $DEBUG;
        return False;
    }

    for split /'.'/, $ip {
        # Check for invalid quads
        unless $_ >= 0 and $_ < 256 {
            warn "Invalid quad in IP address $ip - $_\n" if $DEBUG;
            return False;
        }
    }

    return True;

} # ip-is-ipv4

#------------------------------------------------------------------------------
# Subroutine ip-is-ipv6
# Purpose : Check if an IP address is version 6
# Params  : IP address
# Returns : True (yes) or False (no)
sub ip-is-ipv6(Str:D $ip is copy --> Bool) is export(:ip-is-ipv6) {
    # we don't use a constraint on the input here so we
    # can report specific problems for debugging

    # Count octets
    # IPv4 must have from 1 to 8 octets (at least one colon)
    my $n = count-substrs($ip, ':');
    return False unless $n > 0 and $n < 8;

    # $k is a counter
    my $k;

    for split ':', $ip {
        ++$k;

        # Empty octet ?
        next if $_ eq '';

        # Normal v6 octet ?
        next if m:i/^ <[a..f\d]> ** 1..4 $/;

        # Last octet - is it IPv4 ?
        if ($k == $n + 1) && ip-is-ipv4($_) {
            ++$n; # ipv4 is two octets
            next;
        }

        warn "Invalid IP address $ip\n" if $DEBUG;
        return False;
    }

    # Does the IP address start with a single : ?
    if $ip ~~ /^ ':' <-[\:]> / {
        warn "Invalid address $ip (starts with :)\n" if $DEBUG;
        return False;
    }

    # Does the IP address finish with a single : ?
    if $ip ~~ / <-[\:]> ':' $/ {
        warn "Invalid address $ip (ends with :)\n" if $DEBUG;
        return False;
    }

    # Does the IP address have more than one '::' pattern ?
    my $ncolonpairs = count-substrs($ip, '::');
    if $ncolonpairs > 1 {
        warn "Invalid address $ip (More than one :: pattern)\n" if $DEBUG;
        return False;
    }

    # number of octets
    if $n != 7 && $ip !~~ /'::'/ {
        warn "Invalid number of octets $ip\n" if $DEBUG;
        return False;
    }

    # valid IPv6 address
    return True;

} # ip-is-ipv6
