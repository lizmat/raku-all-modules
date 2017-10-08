use v6;

use DNS::Zone::ResourceRecordData;

class DNS::Zone::ResourceRecordData::SOA is DNS::Zone::ResourceRecordData
{
	has $.domainName   is required;
	has $.domainAction is required;
	has $.serial       is required;
	has $.refresh      is required;
	has $.retry        is required;
	has $.expire       is required;
	has $.min          is required;

	has $!changed = False;

	method isChanged { $!changed }

	method domainName   { self!proxy($!domainName)   }
	method domainAction { self!proxy($!domainAction) }
	method serial       { self!proxy($!serial)       }
	method refresh      { self!proxy($!refresh)      }
	method retry        { self!proxy($!retry)        }
	method expire       { self!proxy($!expire)       }
	method min          { self!proxy($!min)          }

	method !proxy(\attr)
	{
		Proxy.new(
			FETCH => { attr },
			STORE => -> $, $value { $!changed = True; attr = $value }
		);
	}

	method gist()
	{
		return "(ResourceRecordDataSOA domainName="~$!domainName~" "~
		        "domainAction="~$!domainAction~" "~
		        "serial="~$!serial~" "~
		        "refresh="~$!refresh~" "~
		        "retry="~$!retry~" "~
		        "expire="~$!expire~" "~
		        "min="~$!min~")";
	}

	method Str()
	{ }

	method gen()
	{
		return "$.domainName $.domainAction $.serial $.refresh $.retry $.expire $.min";
	}

	method type()
	{ "SOA" }
}
