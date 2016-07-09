

use v6;

use RefOptionSet;
use NIException;
use Errno;

role Parser does RefOptionSet {
	multi method parse(Blob $data) returns Array {
		X::NotImplement.new().throw();
	}

	multi method parse(Str $data) returns Array {
		X::NotImplement.new().throw();
	}

	multi method parse(Errno @data) returns Array {
		return @data;
	}
}

#`(
	<tr><td data-th="Return code/value"><a id="WSA_INVALID_HANDLE"></a><a id="wsa_invalid_handle"></a><dl>
	<dt><strong>WSA_INVALID_HANDLE</strong></dt>
	<dt>6</dt>
	</dl>
	</td><td data-th="Description">
	<p></p>
	<dl>
	<dt><a id="Specified_event_object_handle_is_invalid."></a><a id="specified_event_object_handle_is_invalid."></a><a id="SPECIFIED_EVENT_OBJECT_HANDLE_IS_INVALID."></a>Specified event object handle is invalid.</dt>
	<dd>
	<p>An application attempts to use an event object, but the specified handle is not valid. Note that this error is returned by the operating system, so the error number may change in future releases of Windows.</p>
	</dd>
	</dl>
	</td></tr>
)

class Parser::Win32Socket does Parser {
	my token Content {
		<-[\>\<]>*
	}

	my token AttributeValue {
		'"' <-[\"\>\<]>* '"'
	}

	my rule TableRow {
		'<tr>'
			'<td' 'data-th='<AttributeValue> '>'
				'<a' 'id='<AttributeValue> '></a>'
				'<a' 'id='<AttributeValue> '></a>'
				'<dl>'
					'<dt>'
					'<strong>'
						<id=Content>
					'</strong>'
					'</dt>'
					'<dt>'
						<number=Content>
					'</dt>'
				'</dl>'
			'</td>'
			'<td' 'data-th='<AttributeValue> '>'
				'<p></p>'
				'<dl>'
					'<dt>'
						'<a' 'id='<AttributeValue> '></a>'
						'<a' 'id='<AttributeValue> '></a>'
						'<a' 'id='<AttributeValue> '></a>'
						<comment=Content>
					'</dt>'
#`(					'<dd>'
					'<p>'
						<commentMajor=Content>
					'</p>'
					'</dd>'
				'</dl>'
			'</td>'
		'</tr>'
)
	}

	multi method parse(Str $data) returns Array {
		my @ret = [];

		if $data ~~ m:g/<TableRow>/ {
			for @$/ -> $match {
				@ret.push(Errno.new(
					errno 	=> ~$match<TableRow><id>,
					number 	=> ~$match<TableRow><number>,
					comment	=> ~$match<TableRow><comment>
				));
			}
		}

		return @ret;
	}
}

class Parser::Win32System does Parser {
	my token AttributeValue {
		'"' <-[\"\>\<]>* '"'
	}

	my token Content {
		<-[\>\<]>*
	}

	my rule SystemErrorChunk {
		'<dt>'
			'<a' 'id='<AttributeValue> '></a>'
			'<a' 'id='<AttributeValue> '></a>'
			'<strong>'
				<id=Content>
			'</strong>'
		'</dt>'
		'<dd>'
			'<dl>'
				'<dt>'
					$<number>=(\d+|\d+ \- \d+)<Content>
				'</dt>'
				'<dt>'
					'<p>'
						<comment=Content>
					'</p>'
				'</dt>'
			'</dl>'
		'</dd>'
	}
	multi method parse(Str $data) returns Array {
		my @ret = [];

		if $data ~~ m:g/<SystemErrorChunk>/ {
			for @($/) -> $match {
				@ret.push(Errno.new(
					errno 	=> ~$match<SystemErrorChunk><id>,
					number 	=> ~$match<SystemErrorChunk><number>,
					comment	=> ~$match<SystemErrorChunk><comment>
				));
			}
		}
		
		return @ret;
	}
}

class Parser::Win32SystemUrl does Parser {
	my token MSLink {
		'https://msdn.microsoft.com'<-[\"\>\<]>*
	}

	my rule Href {
		'<a' 'href='\"<MSLink>\" '>''System Error Codes '<-[\>\<]>* '</a>'
	}

	multi method parse(Str $data) returns Array {
		my @rets = [];

		if $data ~~ m:g/<Href>/ {
			for @$/ -> $match {
				@rets.push: ~$match<Href><MSLink>;
			}
		}

		return @rets;
	}
}

class Parser::Linux does Parser {

}
