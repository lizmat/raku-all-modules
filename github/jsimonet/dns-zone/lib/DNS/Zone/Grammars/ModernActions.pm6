use v6;

use DNS::Zone::ResourceRecord;
use DNS::Zone::ResourceRecordData;
use DNS::Zone::ResourceRecordData::A;
use DNS::Zone::ResourceRecordData::AAAA;
use DNS::Zone::ResourceRecordData::MX;
use DNS::Zone::ResourceRecordData::CNAME;
use DNS::Zone::ResourceRecordData::DNAME;
use DNS::Zone::ResourceRecordData::NS;
use DNS::Zone::ResourceRecordData::SOA;
use DNS::Zone::ResourceRecordData::PTR;
use DNS::Zone::ResourceRecordData::TXT;
use DNS::Zone::ResourceRecordData::SRV;
use DNS::Zone::ResourceRecordData::SPF;

=begin pod
=head1 Synopsis
=para
	The action of the grammar DNSZone. This class aims to create a comprehensible AST,
	giving the possibility to manipulate it easily (add/remove/alter some lines).
=end pod
class DNS::Zone::ModernActions
{

	# Used for creating the AST, does not export from this file.
	my class Type
	{
		has Str                $.type is rw;
		has DNS::Zone::ResourceRecordData $.rdata is rw;
	}

	# Return a hash of ResourceRecords.
	method TOP($/)
	{
		# Add to the Zone object only ResourceRecord entries
		#make Zone.new(
		#	rr => grep( { $_.ast ~~ ResourceRecord }, @<entry> )».ast
		#);
		make grep( { $_.ast ~~ DNS::Zone::ResourceRecord }, @<entry> )».ast;

		# $<soa>.elems == 1
		# $<NS>.elems > 0
		# Check for errors
	}

	method entry($/)
	{
		if $<resourceRecord>
		{
			make $<resourceRecord>.ast;
		}
	}

	# Include a file into current zone
	# @TODO
	method controlEntryAction:sym<INCLUDE>($/)
	{ }

	method resourceRecord($/)
	{
		# say "domain name = $<domainName> ; ttl = "~$<ttlOrClass><ttl>~ " ; class = "~ $<ttlOrClass><class>.Str~ " ; type = "~$<type>.ast.type.Str~ " ; rdata = "~$<type>.ast.rdata;
		my $domainName = '';
		$domainName = $<domainName>.Str if $<domainName>.chars;
		make DNS::Zone::ResourceRecord.new( domainName => $domainName,
		                                    ttl        => $<ttlOrClass><ttl>.Str,
		                                    class      => $<ttlOrClass><class>.Str,
		                                    type       => $<type>.ast.type.Str,
		                                    rdata      => $<type>.ast.rdata );
	}

	method domainName:sym<fqdn>($/)
	{ make $/.Str; }

	method domainName:sym<labeled>($/)
	{ make $/.Str; }

	method domainName:sym<@>($/)
	{ make $/.Str; }

	method ttl($/)
	{
		make $/;
	}

	method type:sym<A>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::A.new(ipAdress => $<rdataA>.Str) );
	}

	method type:sym<AAAA>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::AAAA.new(ip6Adress => $<rdataAAAA>.Str) );
	}

	method type:sym<MX>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::MX.new(
		                        mxPref     => $<mxPref>,
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<CNAME>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::CNAME.new(
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<DNAME>($/)
	{
		make Type.new( type => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::DNAME.new(
		                        domainName => $<domainName>.Str ) );
	}

	method type:sym<NS>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::NS.new(
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<SOA>($/)
	{
		make Type.new( type  => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::SOA.new(
		                        domainName   => $<rdataSOA>.<domainName>.Str,
		                        domainAction => $<rdataSOA>.<rdataSOAActionDomain>.Str,
		                        serial       => $<rdataSOA>.<rdataSOASerial>.Str,
		                        refresh      => $<rdataSOA>.<rdataSOARefresh>.Str,
		                        retry        => $<rdataSOA>.<rdataSOARetry>.Str,
		                        expire       => $<rdataSOA>.<rdataSOAExpire>.Str,
		                        min          => $<rdataSOA>.<rdataSOAMin>.Str ) );
	}

	method type:sym<PTR>($/)
	{
		make Type.new( type => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::PTR.new(
		                        domainName => $<domainName>.Str) );
	}

	method type:sym<TXT>($/)
	{
		make Type.new( type => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::TXT.new(
		                        txt => $<rdataTXT>.Str ) );
	}

	method type:sym<SRV>($/)
	{
		make Type.new( type => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::SRV.new(
		                        priority => $<rdataSRV>.<rdataSRVPriority>.Int,
		                        weight   => $<rdataSRV>.<rdataSRVWeight>.Int,
		                        port     => $<rdataSRV>.<rdataSRVPort>.Int,
		                        target   => $<rdataSRV>.<rdataSRVTarget>.Str
		                        )
		             );
	}

	method type:sym<SPF>($/)
	{
		make Type.new( type => $<typeName>.Str,
		               rdata => DNS::Zone::ResourceRecordData::SPF.new(
		                        spf => $<rdataTXT>.Str ) );
	}

}
