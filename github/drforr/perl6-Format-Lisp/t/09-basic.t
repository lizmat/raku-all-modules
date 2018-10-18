use v6;

use Test;
use lib 't/lib';
use Utils;
use Format::Lisp;

my $fl = Format::Lisp.new;

subtest {
	is $fl.format( Q{} ), Q{}, Q{no arguments};

	subtest {
		is $fl.format( Q{}, 1 ), Q{}, Q{number};
		is $fl.format( Q{}, 'foo' ), Q{}, Q{string};
		is $fl.format( Q{}, $fl.formatter( Q{} ) ), Q{}, Q{formatter};
	}, Q{unused arguments};
}, Q{empty format};

subtest {
	subtest {
		is $fl.format( Q{a} ), Q{a}, Q{ASCII};
		is $fl.format( Q{Ø} ), Q{Ø}, Q{Latin-1};
		is $fl.format( Q{ऄ} ), Q{ऄ}, Q{Devanagari};
	}, Q{no arguments};

	subtest {
		is $fl.format( Q{a}, 1 ), Q{a}, Q{ASCII};
		is $fl.format( Q{Ø}, 2, Q{foo} ), Q{Ø}, Q{Latin-1};
		is $fl.format( Q{ऄ}, 3, $fl.formatter( "" ) ), Q{ऄ}, Q{Devanagari};
	}, Q{unused arguments};
}, Q{text, no directives};

subtest {
	is $fl.format( qq{~\n} ), Q{}, 'newline';

	subtest {
#`(
		throws-ok {
			$fl.format( Q{~$} )
		} X::Format-Error, 'no arguments';
)

		is $fl.format( Q{~$}, Q{} ), Q{}, 'empty argument';
#`(
		is $fl.format( Q{~$}, 1 ), Q{1.00}, 'integer';
		is $fl.format( Q{~$}, 1.23 ), Q{1.23}, 'floating point';
)
	}, 'dollar';

	is $fl.format( Q{~%} ), qq{\n}, 'percent';

	is $fl.format( Q{~&} ), Q{}, 'ampersand';

	is $fl.format( Q{~(~)} ), Q{}, 'parentheses';

	subtest {
#`(
		throws-ok {
			$fl.format( Q{~*} )
		} X::Format-Error, 'no arguments';
)

		is $fl.format( Q{~*}, Q{} ), Q{}, 'one argument';
	}, 'asterisk (goto)';

#`(
	# ~+ is like ~v
	throws-ok {
		$fl.format( Q{~+} )
	} X::Format-Error, '~+ invalid';
)

#`(
	# ~, triggers a serious exception
	throws-ok {
		$fl.format( Q{~,} )
	} X::Format-Error, '~, invalid';
)

#`(
	# ~- is like ~v
	throws-ok {
		$fl.format( Q{~+} )
	} X::Format-Error, '~+ invalid';
)

#`(
	# ~. is invalid
	throws-ok {
		$fl.format( Q{~.} )
	} X::Format-Error, '~. invalid';
)

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~/} )
		} X::Format-Error, 'unbalanced';
)

#`(
		throws-ok {
			$fl.format( Q{~//} )
		} X::Format-Error, 'no arguments';
)

#`(
		is $fl.format( Q{~//}, Q{}, Nil ), Q{}, 'one argument';
)
	}, '/';
)

	is $fl.format( Q{~<~>} ), Q{}, 'angles';

	subtest {
#`(
		throws-ok {
			$fl.format( Q{~;} )
		} X::Format-Error, 'no arguments';
)

#`(
		throws-ok {
			$fl.format( Q{~(~;~)} )
		} X::Format-Error, 'not inside [] <>';
)

#`(
		throws-ok {
			$fl.format( Q{~{~;~}} )
		} X::Format-Error, 'not inside [] <>';
)

		is $fl.format( Q{~<~;~>} ), Q{}, 'inside angles';
	}, 'semicolon';

	subtest {
#`(
		throws-ok {
			$fl.format( Q{~?} )
		} X::Format-Error, 'no arguments';
)

		is $fl.format( Q{~?}, Q{}, Nil ), Q{}, 'one argument';
	}, 'question';

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~A} )
		} X::Format-Error, 'no arguments';
)

#`(
		is $fl.format( Q{~A}, Q{} ), Q{}, 'one argument';
)
	}, 'A';
)

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~B} )
		} X::Format-Error, 'no arguments';
)

#`(
		is $fl.format( Q{~B}, Q{} ), Q{}, 'one argument';
)
	}, 'B';
)

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~C} )
		} X::Format-Error, 'no arguments';
)

#`(
		throws-ok {
			$fl.format( Q{~C}, Q{foo} )
		} X::Format-Error, 'bad type';
)

#`(
		is $fl.format( Q{~C}, Q{} ), Q{}, 'C';
)
	}, 'C';
)

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~D} )
		} X::Format-Error, 'no arguments';
)

#`(
		is $fl.format( Q{~D}, Q{} ), Q{}, 'one argument';
)
	}, 'D';
)

	subtest {
#`(
		throws-ok {
			$fl.format( Q{~E} )
		} X::Format-Error, 'no arguments';
)

		is $fl.format( Q{~E}, Q{} ), Q{}, 'one argument';
	}, 'E';

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~F} )
		} X::Format-Error, 'no arguments';
)

#`(
		is $fl.format( Q{~F}, Q{} ), Q{}, 'one argument';
)
	}, 'F';
)

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~G} )
		} X::Format-Error, 'no arguments';
)

#`(
		is $fl.format( Q{~G}, Q{} ), Q{}, 'one argument';
)
	}, 'G';
)

#`(
	throws-like {
		$fl.format( Q{~H} )
	}, X::Format-Error, '~H invalid';
)

	# ~H doesn't exist

	subtest {
#`(
		throws-ok {
			$fl.format( Q{~I} )
		} X::Format-Error, 'no arguments';
)

		is $fl.format( Q{~I}, Q{} ), Q{}, 'one argument';
	}, 'I';

#`(
	throws-ok {
		$fl.format( Q{~J} )
	} X::Format-Error, '~J invalid';
)

#`(
	throws-ok {
		$fl.format( Q{~K} )
	} X::Format-Error, '~K invalid';
)

#`(
	throws-ok {
		$fl.format( Q{~L} )
	} X::Format-Error, '~L invalid';
)

#`(
	throws-ok {
		$fl.format( Q{~M} )
	} X::Format-Error, '~M invalid';
)

#`(
	throws-ok {
		$fl.format( Q{~N} )
	} X::Format-Error, '~N invalid';
)

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~O} )
		} X::Format-Error, 'no arguments';
)

#`(
		is $fl.format( Q{~O}, Q{} ), Q{}, 'one argument';
)
	}, 'O';
)

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~P} )
		} X::Format-Error, 'no arguments';
)

#`(
		$fl.format( Q{~P}, Q{} )
)
	}, 'P';
)

#`(
	throws-ok {
		$fl.format( Q{~Q} )
	} X::Format-Error, '~Q invalid';
)

	# ~Q does not exist

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~R} )
		} X::Format-Error, 'no arguments';

		throws-ok {
			$fl.format( Q{~R}, Q{} )
		} X::Format-Error, 'wrong type';
)

#`(
		is $fl.format( Q{~R}, Q{1} ), Q{1}, 'one argument';
)
	}, 'R';
)

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~S} )
		} X::Format-Error, 'no arguments';
)

#`(
		is $fl.format( Q{~S}, Q{} ), Q{""}, 'one argument';
)
	}, 'S';
)

#`(
	is $fl.format( Q{~T} ), Q{ }, 'T';
)

#`(
	throws-ok {
		$fl.format( Q{~U} )
	} X::Format-Error, '~U invalid';
)

	# ~U does not exist
#`(
	throws-ok {
		$fl.format( Q{~V} )
	} X::Format-Error, '~V invalid';
)

	# ~V is just plain weird. Claims unterminated string.
	# Maybe Unicode completion?

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~W} )
		} X::Format-Error, 'no arguments';
)

#`(
		is $fl.format( Q{~W}, Q{} ), Q{""}, 'one argument';
)
	}, 'W';
)

#`(
	subtest {
#`(
		throws-ok {
			$fl.format( Q{~X} )
		} X::Format-Error, 'no arguments';
)

#`(
		is $fl.format( Q{~X}, Q{} ), Q{}, 'one argument';
)
	}, 'X';
)

#`(
	throws-ok {
		$fl.format( Q{~Y} )
	} X::Format-Error, '~Y invalid';
)

#`(
	throws-ok {
		$fl.format( Q{~Z} )
	} X::Format-Error, '~Z invalid';
)

	subtest {
#`(
		throws-ok {
			$fl.format( Q{~[~]} )
		} X::Format-Error, 'no arguments';
)

		is $fl.format( Q{~[~]}, Q{} ), Q{}, 'one argument';
	}, '[]';


	is $fl.format( Q{~^} ), Q{}, '^';

	is $fl.format( Q{~_} ), Q{}, '_';
#`(
	throws-ok {
		$fl.format( Q{~`} )
	} X::Format-Error, '~` invalid';
)

	# XXX *not* reiterating the lower-case letters here...

	subtest {
#`(
		throws-ok {
			$fl.format( Q[~\{~\}] )
		} X::Format-Error, 'no arguments';
)

		is $fl.format( Q[~{~}], Q{} ), Q{}, 'one argument';
	}, '\{\}';

#`(
	is $fl.format( Q{~|} ), qq{\n }, '|';
)

	is $fl.format( Q{~~} ), Q{~}, '~';

}, Q{single unnested directive, in ASCII order};

done-testing;

# vim: ft=perl6
