use v6;

# use Grammar::Debugger;
# use Grammar::Tracer;

=begin pod
=synopsis Grammar to parse a dns zone file, including RFC 1035.
=author Julien Simonet
=version 0.1
=end pod
grammar DNS::Zone::Grammars::Modern {

	# Used to check the domain name lengh.
	my constant $maxDomainNameLengh = 254;

	# Used to check the TXT data.
	my constant $maxRdataTXTLengh = 255;

	# Each parts of a domain name (insided '.') can have a maximum lengh.
	my constant $maxLabelDomainNameLengh = 63;

	# TODO
	# The origin of the zone, used to check if domains are inside the zone,
	# and to check if NS is defined
	my $origin = '';

	method parse( |c ) {
		# Used to count opened parentheses.
		my $*parenCount = 0;

		# Used to check if ttl is specified.
		my $*currentTTL;

		# is $ttl or soa already encountered.
		my Bool $*encounteredTTL = False;

		# The last encountered domain name
		my $*currentDomainName;

		nextwith |c;
	}

	# Entry point
	token TOP {
		<entry>* % [ \v+ ] { $*parenCount = 0; }
	}

	# A DNS zone file is composed of entries
	# If no '(' at the start of the line, no space before resourceRecord.
	token entry {
		[ <paren> <rrSpace>* ]?
		[
			<resourceRecord> \h* <commentWithoutNewline>?
			# Current TTL and current domain name have to be defined
			<?{ $*currentTTL && $*currentDomainName }>
			|
			<controlEntry>
			|
			<commentWithoutNewline>
		]?
		[ <rrSpace> <commentWithoutNewline>? ]?
		<?{ $*parenCount == 0 }>
		#<error> \v*
	}

	# An error occured, try to continue parsing
	#token error { \N+ }

	# COMMENTS
	token commentWithoutNewline { ';' \N*     } # ;comment
	token comment               { ';' \N* \n? } # ;comment\n

	# CONTROL ENTRIES
	# Used to set variable values, like TTL or ORIGIN.
	token controlEntry {
		'$' <controlEntryAction>
	}

	proto token controlEntryAction { * }
	token controlEntryAction:sym<TTL> {
		[ :i 'ttl' ] \h+ <ttl>
		{
			$*encounteredTTL = True;
			$*currentTTL = $<ttl>.Str.Numeric;
		}
	}

	token controlEntryAction:sym<ORIGIN>  { [ :i 'origin' ] \h+ <domainName> }
	# TODO
	#token controlEntryAction:sym<INCLUDE> { [:i 'include'] \h+ <fileName>   }

	# Resource record
	# If a domain name is matched, the current domain name will be updated.
	# A domain name can be empty only in resource record. In this case, the line
	# have to begin with a space, and the current domain name will be used.
	token resourceRecord {
		[ <domainName> | $<domainName> = '' ] <rrSpace>+ <ttlOrClass> <type> <rrSpace>*

		# Save current domain name if it is specified
		{ $*currentDomainName = $<domainName>.Str if $<domainName>.chars; }

		# Fail if grammar match an _ and the type is not SRV
		<!{ ($<domainName>.index( '_' )).defined &&
			$<type><typeName>.Str !~~ /:i SRV/ }>
	}

	# DOMAIN NAME
	# can be any of :
	# domain subdomain.domain domain.tld. @
	proto token domainName { * }

	token domainName:sym<fqdn> {
		# Same as labeled but with a final dot
		<domainNameLabel> ** { 1 .. $maxDomainNameLengh/2 }  % '.' '.'
		<?{ $/.Str.chars <= $maxDomainNameLengh; }>
	}

	token domainName:sym<labeled> {
		<domainNameLabel> ** { 1 .. $maxDomainNameLengh/2 }  % '.'
		<?{ $/.Str.chars + 1 + $origin.chars < $maxDomainNameLengh }>
		# Lengh of matched string + lenght of the point + lenght of the origin
	}

	token domainName:sym<@> { '@' }

	token domainNameLabel {
		<domainNameLabelChar> [ <domainNameLabelChar> | '-' ] ** {0 .. $maxLabelDomainNameLengh - 1}
	}

	token domainNameLabelChar {
		<[a..zA..Z0..9_]>
	}

	# TTL AND CLASS
	# <ttl> & <class> are optionals
	# A <class> or a <ttl>, is followed by a <rrSpace>.
	# If no class or <ttl> are matched, no <rrSpace> either so parenthese
	# count is ok
	token ttlOrClass {
		[ [ <class> | <ttl> ] <rrSpace>+ ] ** 0..2
		<?{ $<class>.elems <= 1 && $<ttl>.elems <= 1 }>

		# TODO save real value of the ttl (depends on $1)
		# Only save ttl if it is not defined (before type soa or $ttl)
		{ defined $<ttl> && ( $*encounteredTTL or $*currentTTL = $<ttl>.Str ) }
	}

	# TTL, can be:
	# 42 1s 2m 3h 4j 5w, respectively seconds, minutes, hours, days and week
	token ttl {
		(<[0..9]>+) (<[smhdw]>?)
		<?{
			# Checks if the final value is positive and
			# inferior to a signed int32
			$0 > 0 && (
				$1 eq 'w' && ($0 * 604800 <= 2147483647) ||
				$1 eq 'd' && ($0 * 86400  <= 2147483647) ||
				$1 eq 'h' && ($0 * 3600   <= 2147483647) ||
				$1 eq 'm' && ($0 * 60     <= 2147483647) ||
				$1 eq 's' && ($0          <= 2147483647) ||
				$1 eq ''  && ($0          <= 2147483647)
			)
		}>
	}

	# CLASS
	proto token class   { * }
	token class:sym<IN> { $<sym> = [ :i 'in' ] } # The Internet
	token class:sym<CH> { $<sym> = [ :i 'ch' ] } # Chaosnet
	token class:sym<HS> { $<sym> = [ :i 'hs' ] } # Hesiod

	# TYPE
	proto token type           { * }
	token type:sym<A>          { $<typeName> = [ :i 'a' ] <rrSpace>+ <rdataA> }
	token type:sym<AAAA>       { $<typeName> = [ :i 'aaaa' ] <rrSpace>+ <rdataAAAA> }
	# token type:sym<AFSDB>      { $<typeName> = '' }
	# token type:sym<APL>        { $<typeName> = '' }
	# token type:sym<AXFR>       { $<typeName> = '' }
	token type:sym<A6>         { $<typeName> = [ :i 'a6' ] <rrSpace>+ <rdataAAAA> } # deprecated ?
	# token type:sym<CAA>        { $<typeName> = [ :i 'caa' ] }
	# token type:sym<CDNSKEY>    { $<typeName> = [ :i 'cdnskey' ] }
	# token type:sym<CDS>        { $<typeName> = [ :i 'cds' ] }
	# token type:sym<CERT>       { $<typeName> = '' }
	token type:sym<CNAME>      { $<typeName> = [ :i 'cname' ] <rrSpace>+ <domainName> }
	# token type:sym<DHCID>      { $<typeName> = '' }
	# token type:sym<DLV>        { $<typeName> = '' }
	token type:sym<DNAME>      { $<typeName> = [ :i 'dname' ] <rrSpace>+ <domainName> }
	# token type:sym<DNSKEY>     { $<typeName> = '' }
	# token type:sym<DS>         { $<typeName> = '' }
	# token type:sym<IPSECKEY>   { $<typeName> = '' }
	# token type:sym<IXFR>       { $<typeName> = '' }
	# token type:sym<GPOS>       { $<typeName> = '' } # deprecated ?
	# token type:sym<HINFO>      { $<typeName> = '' } # deprecated ?
	# token type:sym<HIP>        { $<typeName> = '' }
	# token type:sym<IPSECKEY>   { $<typeName> = '' }
	# token type:sym<ISDN>       { $<typeName> = '' } # deprecated ?
	# token type:sym<KEY>        { $<typeName> = '' }
	# token type:sym<KX>         { $<typeName> = '' }
	# token type:sym<LOC>        { $<typeName> = '' }
	token type:sym<MX>         { $<typeName> = [ :i 'mx' ] \h+ <mxPref> \h+ <domainName> }
	# token type:sym<NAPTR>      { $<typeName> = '' }
	# token type:sym<OPT>        { $<typeName> = '' }
	token type:sym<NS>         { $<typeName> = [ :i 'ns' ] \h+ <domainName> }
	# token type:sym<NSAP>       { $<typeName> = '' } # deprecated ?
	# token type:sym<NSEC>       { $<typeName> = '' }
	# token type:sym<NSEC3>      { $<typeName> = '' }
	# token type:sym<NSEC3PARAM> { $<typeName> = '' }
	# token type:sym<NXT>        { $<typeName> = '' } # deprecated ?
	token type:sym<PTR>        { $<typeName> = [ :i 'ptr' ] <rrSpace>+ <domainName> }
	# token type:sym<PX>         { $<typeName> = '' } # deprecated ?
	# token type:sym<RP>         { $<typeName> = '' }
	# token type:sym<RRSIG>      { $<typeName> = '' }
	# token type:sym<RT>         { $<typeName> = '' } # deprecated ?
	# token type:sym<SIG>        { $<typeName> = '' }
	token type:sym<SOA>        { $<typeName> = [ :i 'soa' ] \h+ <rdataSOA> }
	token type:sym<SPF>        { $<typeName> = [ :i 'spf' ] \h+ <rdataTXT> } #TODO defined in RFC 4408 and discontinued by RFC 7208
	token type:sym<SRV>        { $<typeName> = [ :i 'srv' ] <rrSpace>+ <rdataSRV> }
	# token type:sym<SSHFP>      { $<typeName> = '' }
	# token type:sym<TA>         { $<typeName> = '' }
	# token type:sym<TKEY>       { $<typeName> = '' }
	# token type:sym<TLSA>       { $<typeName> = '' }
	# token type:sym<TSIG>       { $<typeName> = '' }
	token type:sym<TXT>        { $<typeName> = [ :i 'txt' ] <rrSpace>+ <rdataTXT> }
	# token type:sym<WKS>        { $<typeName> = '' }
	# token type:sym<X25>        { $<typeName> = '' }

	# Resource Record data
	# depends on TYPE
	# TODO simplify : directly use IPv[46] in type tokens
	token rdataA {<ipv4>}
	token rdataAAAA {<ipv6>}

	# IPv4
	token ipv4 {
		<d8> ** 4 % '.' # From http://rosettacode.org/wiki/Parse_an_IP_Address#Perl_6
	}

	# IPV6
	# If only "single" semi-colon are present, the count of <h16> have to be == 8
	# Only one "double" semi-colon, and the count of <h16> have to be < 8
	# IPv6 can end with IPv4 notation:
	#   exemple: 0:0:0:0:0:FFFF:129.144.52.38
	# http://tools.ietf.org/html/rfc2373#section-2.2
	# IPv4 possible regex:
	#   ^(^(([0-9A-F]{1,4}(((:[0-9A-F]{1,4}){5}::[0-9A-F]{1,4})|((:[0-9A-F]{1,4}){4}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,1})|((:[0-9A-F]{1,4}){3}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,2})|((:[0-9A-F]{1,4}){2}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,3})|(:[0-9A-F]{1,4}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,4})|(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,5})|(:[0-9A-F]{1,4}){7}))$|^(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,6})$)|^::$)|^((([0-9A-F]{1,4}(((:[0-9A-F]{1,4}){3}::([0-9A-F]{1,4}){1})|((:[0-9A-F]{1,4}){2}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,1})|((:[0-9A-F]{1,4}){1}::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,2})|(::[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,3})|((:[0-9A-F]{1,4}){0,5})))|([:]{2}[0-9A-F]{1,4}(:[0-9A-F]{1,4}){0,4})):|::)((25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})\.){3}(25[0-5]|2[0-4][0-9]|[0-1]?[0-9]{0,2})$$
	# @see t/ipv6.t

	# Need to test sequencely <h16> part because some <d8> can be interpreted as <h16> tokens, like
	# 1000::10.0.0.1 The "10" is interpreted as <h16> and <ipv6> token fails.
	token ipv6 {
		<doubleColon> <ipv4> |
		[
			<h16>                                        <doubleColon>   <ipv4> |
			<h16> ** 2 %         <doubleColon>   [ ':' | <doubleColon> ] <ipv4> |
			<h16> ** 3 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4> |
			<h16> ** 4 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4> |
			<h16> ** 5 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4> |
			<h16> ** 6 % [ ':' | <doubleColon> ] [ ':' | <doubleColon> ] <ipv4> |
			<doubleColon>? <h16> ** 0..8 % [ ':' | <doubleColon> ]
		]
		<?{
			(
				(
					$<doubleColon>.elems == 0 && (
						( $<h16>.elems == 8 ) ||
						( $<h16>.elems == 6 && $<ipv4><d8>.elems == 4 )
					)
				)
				||
				(
					$<doubleColon>.elems == 1 && (
						( $<h16>.elems < 8 ) ||
						( $<h16>.elems < 6  && $<ipv4><d8>.elems ==  4 )
					)
				)
			)
		}>
	}

	token doubleColon {
		'::'
	}

	# MX preference
	token mxPref {
		\d ** 1..2
	}

	# TODO : check domain & rdataSOAActionDomain are correct
	token rdataSOA {
		<domainName> <rrSpace>+ <rdataSOAActionDomain> <rrSpace>*
		<rdataSOASerial> <rrSpace>* <comment>?
		<rrSpace>* <rdataSOARefresh> <rrSpace>* <comment>?
		<rrSpace>* <rdataSOARetry>   <rrSpace>* <comment>?
		<rrSpace>* <rdataSOAExpire>  <rrSpace>* <comment>?
		<rrSpace>* <rdataSOAMin> <rrSpace>* <commentWithoutNewline>*

		{
			$*encounteredTTL = True;
			$*currentTTL //= $<rdataSOAMin>.Str.Numeric unless $*currentTTL;
		}
	}

	token rdataSOAActionDomain { <domainName> }
	token rdataSOASerial       { <d32>        }
	token rdataSOARefresh      { <d32>        }
	token rdataSOARetry        { <d32>        }
	token rdataSOAExpire       { <d32>        }
	token rdataSOAMin          { <d32>        }

	token rdataTXT {
		[ <text> | <quotedText> ]+
		<?{ $/.Str.chars < $maxRdataTXTLengh }>
	}

	# A suit of chars, without spaces
	token text {
		[ <-[ ( ) \v " \ ]> | <rrSpace> | '\"']+
	}

	# A suit of chars, with space availables
	token quotedText {
		'"' [ <-[ \n " ]> | "\\\n" | '\"' ]* '"'
	}

	token rdataSRV {
		<rdataSRVPriority> <rrSpace>
		<rdataSRVWeight>   <rrSpace>
		<rdataSRVPort>     <rrSpace>
		<rdataSRVTarget>
	}

	token rdataSRVPriority { <d16>        }
	token rdataSRVWeight   { <d16>        }
	token rdataSRVPort     { <d16>        }
	token rdataSRVTarget   { <domainName> }

	# int 8 bits
	token d8 {
		\d+ <?{ $/ < 256 }> # or $/ < 2 ** 8
	}

	# int 16 bits
	token d16 {
		\d+ <?{ $/ < 65536 }> # or $/ < 2 ** 16
	}

	# int 32 bits
	token d32 {
		\d+ <?{ $/ < 4294967296 }> # or $/ < 2 ** 32
	}

	# hexadecimal 16 bits
	token h16 {
		<:hexdigit> ** 1..4
	}

	# A resource record space (more or less)
	# Can be a classic space, or a ( or )
	# for \n space, at least one ( have to be matched
	# It can contains a comment wich have to be inside a () sequence
	token rrSpace {
		[
			\h          |
			<rrNewLine> |
			<paren>
		]+
		[ <commentWithoutNewline> <rrNewLine> ]?
	}

	# A resource record specific new line
	# Match only if $parenCount is positive, in other words,
	# if we are currently in a multi-line sequence
	token rrNewLine {
		\n <?{ $*parenCount > 0; }>
	}

	# PAREN
	# Parenthese definition
	proto token paren { * }
	token paren:sym<po> { '(' { $*parenCount++; } }
	token paren:sym<pf> { ')' <?{ $*parenCount > 0; }> { $*parenCount--; } }
}
