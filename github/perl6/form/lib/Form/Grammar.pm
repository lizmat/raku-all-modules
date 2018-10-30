grammar Form::Grammar {
	regex TOP {
		^ <field_or_literal>* $
	}

	regex field_or_literal {
		  <field>
		| <literal>
	}

	regex literal {
		<-[{]>+
	}

	regex field {
		'{'
		[
		    <bottom_aligned_field>
		  | <centre_aligned_field>
		  | <top_aligned_field>
		]
		'}'
	}

	regex bottom_aligned_field {
		[ _ <aligned_field> _? ] | [ <aligned_field> _ ]
	}

	regex centre_aligned_field {
		[ '=' <aligned_field> '='? ] | [ <aligned_field> '=' ]
	}

	regex top_aligned_field {
		<aligned_field>
	}

	regex aligned_field {
		  <left_justified_field>
		| <centred_field>
		| <right_justified_field>
		| <fully_justified_field>
		| <numeric_field>
		| <verbatim_field>
	}

	regex left_justified_field {
		  <left_justified_block_field>
		| <left_justified_line_field>
	}

	regex left_justified_block_field {
		'['+
	}

	regex left_justified_line_field {
		'<'+
	}

	regex centred_field {
		  <centred_block_field>
		| <centred_line_field>
	}

	regex centred_block_field {
		  [ ']'+ '['+ ]
		| [ 'I'+ ]
	}

	regex centred_line_field {
		  [ '>'+ '<'+ ]
		| [ '|'+ ]
	}

	regex right_justified_field {
		  <right_justified_block_field>
		| <right_justified_line_field>
	}

	regex right_justified_block_field {
		']'+
	}
	
	regex right_justified_line_field {
		'>'+
	}

	regex fully_justified_field {
		  <justified_block_field>
		| <justified_line_field>
	}

	regex justified_block_field {
		'['+ ']'+
	}

	regex justified_line_field {
		'<'+ '>'+
	}

	regex numeric_field {
		  <numeric_block_field>
		| <numeric_line_field>
	}

	regex numeric_block_field {
		(']'+) '.' ('['+)
	}

	regex numeric_line_field {
		('>'+) '.' ('<'+)
	}

	regex verbatim_line_field {
		'\''+
	}

	regex verbatim_block_field {
		'"'+
	}

	regex verbatim_field {
		  <verbatim_line_field>
		| <verbatim_block_field>
	}
}


# vim: ft=perl6 ts=4 sw=4 noexpandtab
