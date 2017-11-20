=begin pod

=begin NAME

Format::Lisp::Grammar - Grammar for Common Lisp format strings

=end NAME

=begin DESCRIPTION

=end DESCRIPTION

=end pod

grammar Format::Lisp::Grammar {
	token signed-integer {
		<[ - + ]>? <unsigned-integer>
	}
	token unsigned-integer {
	|	<[ 1..9 ]> <[ 0..9 ]>*
	|	0
	}

	token Default { '#' }

	token Character {
	|	<[ a..z A..Z , * ]>
	}

	token V { <[ v V ]> }
	token At { <[ @ ]> }
	token Colon { <[ : ]> }

	token not-Tilde { <-[ ~ ]>+ }

	token value {
	|	<Default>
	|	'\'' <Character>
	|	<V>
	|	<signed-integer>
	}

	token options {
	|	<At> <Colon>
	|	<At>
	|	<Colon> <At>
	|	<Colon>
	}

	token value-comma {
		<value>? ','
	}

	token Tilde-Options {
		<value-comma> ** 0..9 <value>? <options>?
	}

	# Unbalanced tokens
	# Yes, <Tilde-Options> can be factored out, it will be later on.
	#
	token tilde-A { <Tilde-Options> <[ a A ]> }
	token tilde-Amp { <Tilde-Options> '&' }
	token tilde-B { <Tilde-Options> <[ b B ]> }
	token tilde-Caret { <Tilde-Options> '^' }
	token tilde-C { <Tilde-Options> <[ c C ]> }
	token tilde-D { <Tilde-Options> <[ d D ]> }
	token tilde-Dollar { <Tilde-Options> '$' }
	token tilde-E { <Tilde-Options> <[ e E ]> }
	token tilde-F { <Tilde-Options> <[ f F ]> }
	token tilde-G { <Tilde-Options> <[ g G ]> }
	token tilde-I { <Tilde-Options> <[ i I ]> }
	token tilde-Newline { <Tilde-Options> "\n" }
	token tilde-O { <Tilde-Options> <[ o O ]> }
	token tilde-P { <Tilde-Options> <[ p P ]> }
	token tilde-Percent { <Tilde-Options> '%' }
	token tilde-Pipe { <Tilde-Options> '|' }
	token tilde-Ques { <Tilde-Options> '?' }
	token tilde-R { <Tilde-Options> <[ r R ]> }
	token tilde-S { <Tilde-Options> <[ s S ]> }
	token tilde-Semi { <Tilde-Options> ';' }
	token tilde-Star { <Tilde-Options> '*' }
	token tilde-T { <Tilde-Options> <[ t T ]> }
	token tilde-Tilde { <Tilde-Options> '~' }
	token tilde-Under { <Tilde-Options> '_' }
	token tilde-W { <Tilde-Options> <[ w W ]> }
	token tilde-X { <Tilde-Options> <[ x X ]> }

	# Balanced tokens
	#
	token tilde-Angle { '<' <TOP>? '~' <Tilde-Options> '>' }
	token tilde-Brace { '{' <TOP>? '~' <Tilde-Options> '}' }
	token tilde-Bracket { '[' <TOP>? '~' <Tilde-Options> ']' }
	token tilde-Paren { '(' <TOP>? '~' <Tilde-Options> ')' }
	token tilde-Slash { '/' ( <-[ / ]>+ ) '/' }

	# Catchall, not quite there yet.
	#
	token tilde-Unused {
		# XXX Really should be '.', come to think of it.
		# XXX but that would require ordering...
		#
		<[ H h J j K k L l M m N n Q q U u V v Y y Z z ` ]>
	}

	token Atom {
	|	'~'
		[
		|	<tilde-A>
		|	<tilde-Amp>
		|	<tilde-B>
		|	<tilde-Caret>
		|	<tilde-C>
		|	<tilde-D>
		|	<tilde-Dollar>
		|	<tilde-E>
		|	<tilde-F>
		|	<tilde-G>
		|	<tilde-I>
		|	<tilde-Newline>
		|	<tilde-O>
		|	<tilde-P>
		|	<tilde-Percent>
		|	<tilde-Pipe>
		|	<tilde-Ques>
		|	<tilde-R>
		|	<tilde-S>
		|	<tilde-Semi>
		|	<tilde-Star>
		|	<tilde-T>
		|	<tilde-Tilde>
		|	<tilde-Under>
		|	<tilde-W>
		|	<tilde-X>
		]

	# These are really <List>-style tokens, will fix this later.
	#
	|	'~' <Tilde-Options>
		[
		|	<tilde-Angle>
		|	<tilde-Brace>
		|	<tilde-Bracket>
		|	<tilde-Paren>
		|	<tilde-Slash>
		|	<tilde-Unused>
		]
	|	<not-Tilde>
	}

	token TOP { <Atom>+ }
}
