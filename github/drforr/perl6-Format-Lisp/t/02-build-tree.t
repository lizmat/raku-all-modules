use v6;

use Test;
use Format::Lisp;
plan 10;

my $fl = Format::Lisp.new;

# Ack. I think running the permutations here will be simpler than trying to
# match all the tests here, which really aren't full coverage. I'll leave the
# original tests here but commented out for a little while though.

subtest {
	is-deeply $fl._parse( Q{~a} ), [ Format::Lisp::Directive::A.new ];
	is-deeply $fl._parse( Q{~A} ), [ Format::Lisp::Directive::A.new ];
	is-deeply $fl._parse( Q{~&} ), [ Format::Lisp::Directive::Amp.new ];
	is-deeply $fl._parse( Q{~b} ), [ Format::Lisp::Directive::B.new ];
	is-deeply $fl._parse( Q{~B} ), [ Format::Lisp::Directive::B.new ];
	is-deeply $fl._parse( Q{~c} ), [ Format::Lisp::Directive::C.new ];
	is-deeply $fl._parse( Q{~C} ), [ Format::Lisp::Directive::C.new ];
	is-deeply $fl._parse( Q{~^} ), [ Format::Lisp::Directive::Caret.new ];
	is-deeply $fl._parse( Q{~d} ), [ Format::Lisp::Directive::D.new ];
	is-deeply $fl._parse( Q{~D} ), [ Format::Lisp::Directive::D.new ];
	is-deeply $fl._parse( Q{~$} ), [ Format::Lisp::Directive::Dollar.new ];
	is-deeply $fl._parse( Q{~e} ), [ Format::Lisp::Directive::E.new ];
	is-deeply $fl._parse( Q{~E} ), [ Format::Lisp::Directive::E.new ];
	is-deeply $fl._parse( Q{~f} ), [ Format::Lisp::Directive::F.new ];
	is-deeply $fl._parse( Q{~F} ), [ Format::Lisp::Directive::F.new ];
	is-deeply $fl._parse( Q{~g} ), [ Format::Lisp::Directive::G.new ];
	is-deeply $fl._parse( Q{~G} ), [ Format::Lisp::Directive::G.new ];
	is-deeply $fl._parse( Q{~i} ), [ Format::Lisp::Directive::I.new ];
	is-deeply $fl._parse( Q{~I} ), [ Format::Lisp::Directive::I.new ];
	is-deeply $fl._parse( Q{~o} ), [ Format::Lisp::Directive::O.new ];
	is-deeply $fl._parse( Q{~O} ), [ Format::Lisp::Directive::O.new ];
	is-deeply $fl._parse( Q{~p} ), [ Format::Lisp::Directive::P.new ];
	is-deeply $fl._parse( Q{~P} ), [ Format::Lisp::Directive::P.new ];
	is-deeply $fl._parse( Q{~%} ), [ Format::Lisp::Directive::Percent.new ];
	is-deeply $fl._parse( Q{~|} ), [ Format::Lisp::Directive::Pipe.new ];
	is-deeply $fl._parse( Q{~?} ), [ Format::Lisp::Directive::Ques.new ];
	is-deeply $fl._parse( Q{~r} ), [ Format::Lisp::Directive::R.new ];
	is-deeply $fl._parse( Q{~R} ), [ Format::Lisp::Directive::R.new ];
	is-deeply $fl._parse( Q{~s} ), [ Format::Lisp::Directive::S.new ];
	is-deeply $fl._parse( Q{~S} ), [ Format::Lisp::Directive::S.new ];
	is-deeply $fl._parse( Q{~;} ), [ Format::Lisp::Directive::Semi.new ];
	is-deeply $fl._parse( Q{~/a/} ), [
		Format::Lisp::Directive::Slash.new(
			text => 'a'
		)
	];
	is-deeply $fl._parse( Q{~*} ), [ Format::Lisp::Directive::Star.new ];
	is-deeply $fl._parse( Q{~t} ), [ Format::Lisp::Directive::T.new ];
	is-deeply $fl._parse( Q{~T} ), [ Format::Lisp::Directive::T.new ];
	is-deeply $fl._parse( Q{~~} ), [ Format::Lisp::Directive::Tilde.new ];
	is-deeply $fl._parse( Q{~_} ), [ Format::Lisp::Directive::Under.new ];
	is-deeply $fl._parse( Q{~w} ), [ Format::Lisp::Directive::W.new ];
	is-deeply $fl._parse( Q{~W} ), [ Format::Lisp::Directive::W.new ];
	is-deeply $fl._parse( Q{~x} ), [ Format::Lisp::Directive::X.new ];
	is-deeply $fl._parse( Q{~X} ), [ Format::Lisp::Directive::X.new ];

	subtest {
		is-deeply $fl._parse( Q{~<~>} ), [
			Format::Lisp::Directive::Angle.new
		];
		is-deeply $fl._parse( Q{~{~}} ), [
			Format::Lisp::Directive::Brace.new
		];
		is-deeply $fl._parse( Q{~[~]} ), [
			Format::Lisp::Directive::Bracket.new
		];
		is-deeply $fl._parse( Q{~(~)} ), [
			Format::Lisp::Directive::Paren.new
		];
	}, 'balanced';

	done-testing;
}, 'single directive, no ornamentation';

subtest {
	subtest {
		is-deeply $fl._parse( Q{~<A~>} ), [
			Format::Lisp::Directive::Angle.new(
				children => [
					Format::Lisp::Text.new( text => 'A' )
				]
			)
		];
		is-deeply $fl._parse( Q{~{A~}} ), [
			Format::Lisp::Directive::Brace.new(
				children => [
					Format::Lisp::Text.new( text => 'A' )
				]
			)
		];
		is-deeply $fl._parse( Q{~[A~]} ), [
			Format::Lisp::Directive::Bracket.new(
				children => [
					Format::Lisp::Text.new( text => 'A' )
				]
			)
		];
		is-deeply $fl._parse( Q{~(A~)} ), [
			Format::Lisp::Directive::Paren.new(
				children => [
					Format::Lisp::Text.new( text => 'A' )
				]
			)
		];

		done-testing;

	}, 'balanced directive with text content';

	subtest {
		is-deeply $fl._parse( Q{~<~A~>} ), [
			Format::Lisp::Directive::Angle.new(
				children => [
					Format::Lisp::Directive::A.new
				]
			)
		];
		is-deeply $fl._parse( Q{~{~A~}} ), [
			Format::Lisp::Directive::Brace.new(
				children => [
					Format::Lisp::Directive::A.new
				]
			)
		];
		is-deeply $fl._parse( Q{~[~A~]} ), [
			Format::Lisp::Directive::Bracket.new(
				children => [
					Format::Lisp::Directive::A.new
				]
			)
		];
		is-deeply $fl._parse( Q{~(~A~)} ), [
			Format::Lisp::Directive::Paren.new(
				children => [
					Format::Lisp::Directive::A.new
				]
			)
		];

		done-testing;

	}, 'balanced directive with directive content';

	done-testing;

}, 'balanced directives';

subtest {
	is-deeply $fl._parse( Q{~A~a} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::A.new
	];
	is-deeply $fl._parse( Q{~A~A} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::A.new
	];
	is-deeply $fl._parse( Q{~A~&} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Amp.new
	];
	is-deeply $fl._parse( Q{~A~b} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::B.new
	];
	is-deeply $fl._parse( Q{~A~B} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::B.new
	];
	is-deeply $fl._parse( Q{~A~c} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::C.new
	];
	is-deeply $fl._parse( Q{~A~C} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::C.new
	];
	is-deeply $fl._parse( Q{~A~^} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Caret.new
	];
	is-deeply $fl._parse( Q{~A~d} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::D.new
	];
	is-deeply $fl._parse( Q{~A~D} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::D.new
	];
	is-deeply $fl._parse( Q{~A~$} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Dollar.new
	];
	is-deeply $fl._parse( Q{~A~e} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::E.new
	];
	is-deeply $fl._parse( Q{~A~E} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::E.new
	];
	is-deeply $fl._parse( Q{~A~f} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::F.new
	];
	is-deeply $fl._parse( Q{~A~F} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::F.new
	];
	is-deeply $fl._parse( Q{~A~g} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::G.new
	];
	is-deeply $fl._parse( Q{~A~G} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::G.new
	];
	is-deeply $fl._parse( Q{~A~i} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::I.new
	];
	is-deeply $fl._parse( Q{~A~I} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::I.new
	];
	is-deeply $fl._parse( Q{~A~o} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::O.new
	];
	is-deeply $fl._parse( Q{~A~O} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::O.new
	];
	is-deeply $fl._parse( Q{~A~p} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::P.new
	];
	is-deeply $fl._parse( Q{~A~P} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::P.new
	];
	is-deeply $fl._parse( Q{~A~%} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Percent.new
	];
	is-deeply $fl._parse( Q{~A~|} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Pipe.new
	];
	is-deeply $fl._parse( Q{~A~?} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Ques.new
	];
	is-deeply $fl._parse( Q{~A~r} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::R.new
	];
	is-deeply $fl._parse( Q{~A~R} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::R.new
	];
	is-deeply $fl._parse( Q{~A~s} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::S.new
	];
	is-deeply $fl._parse( Q{~A~S} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::S.new
	];
	is-deeply $fl._parse( Q{~A~;} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Semi.new
	];
	is-deeply $fl._parse( Q{~A~/a/} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Slash.new(
			text => 'a'
		)
	];
	is-deeply $fl._parse( Q{~A~*} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Star.new
	];
	is-deeply $fl._parse( Q{~A~t} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::T.new
	];
	is-deeply $fl._parse( Q{~A~T} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::T.new
	];
	is-deeply $fl._parse( Q{~A~~} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Tilde.new
	];
	is-deeply $fl._parse( Q{~A~_} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Under.new
	];
	is-deeply $fl._parse( Q{~A~w} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::W.new
	];
	is-deeply $fl._parse( Q{~A~W} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::W.new
	];
	is-deeply $fl._parse( Q{~A~x} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::X.new
	];
	is-deeply $fl._parse( Q{~A~X} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::X.new
	];

	done-testing;
}, 'balanced directives';

subtest {
	is-deeply $fl._parse( Q{~A~<~>} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Angle.new
	];
	is-deeply $fl._parse( Q{~A~{~}} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Brace.new
	];
	is-deeply $fl._parse( Q{~A~[~]} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Bracket.new
	];
	is-deeply $fl._parse( Q{~A~(~)} ), [
		Format::Lisp::Directive::A.new,
		Format::Lisp::Directive::Paren.new
	];

	done-testing;
		
}, 'atom and balanced directives';

subtest {
	is-deeply $fl._parse( Q{a~aa} ), [
		Format::Lisp::Text.new( text => 'a' ),
		Format::Lisp::Directive::A.new,
		Format::Lisp::Text.new( text => 'a' )
	];
	is-deeply $fl._parse( Q{A~AA} ), [
		Format::Lisp::Text.new( text => 'A' ),
		Format::Lisp::Directive::A.new,
		Format::Lisp::Text.new( text => 'A' )
	];
	is-deeply $fl._parse( Q{&~&&} ), [
		Format::Lisp::Text.new( text => '&' ),
		Format::Lisp::Directive::Amp.new,
		Format::Lisp::Text.new( text => '&' )
	];
	is-deeply $fl._parse( Q{<~<~>>} ), [
		Format::Lisp::Text.new( text => '<' ),
		Format::Lisp::Directive::Angle.new,
		Format::Lisp::Text.new( text => '>' )
	];
	is-deeply $fl._parse( Q{>~<~><} ), [
		Format::Lisp::Text.new( text => '>' ),
		Format::Lisp::Directive::Angle.new,
		Format::Lisp::Text.new( text => '<' )
	];
	is-deeply $fl._parse( Q{b~bb} ), [
		Format::Lisp::Text.new( text => 'b' ),
		Format::Lisp::Directive::B.new,
		Format::Lisp::Text.new( text => 'b' )
	];
	is-deeply $fl._parse( Q{B~BB} ), [
		Format::Lisp::Text.new( text => 'B' ),
		Format::Lisp::Directive::B.new,
		Format::Lisp::Text.new( text => 'B' )
	];
	is-deeply $fl._parse( Q[{~{~}}] ), [
		Format::Lisp::Text.new( text => '{' ),
		Format::Lisp::Directive::Brace.new,
		Format::Lisp::Text.new( text => '}' )
	];
	is-deeply $fl._parse( Q[}~{~}{] ), [
		Format::Lisp::Text.new( text => '}' ),
		Format::Lisp::Directive::Brace.new,
		Format::Lisp::Text.new( text => '{' )
	];
	is-deeply $fl._parse( Q{[~[~]]} ), [
		Format::Lisp::Text.new( text => '[' ),
		Format::Lisp::Directive::Bracket.new,
		Format::Lisp::Text.new( text => ']' )
	];
	is-deeply $fl._parse( Q{]~[~][} ), [
		Format::Lisp::Text.new( text => ']' ),
		Format::Lisp::Directive::Bracket.new,
		Format::Lisp::Text.new( text => '[' )
	];
	is-deeply $fl._parse( Q{c~cc} ), [
		Format::Lisp::Text.new( text => 'c' ),
		Format::Lisp::Directive::C.new,
		Format::Lisp::Text.new( text => 'c' )
	];
	is-deeply $fl._parse( Q{C~CC} ), [
		Format::Lisp::Text.new( text => 'C' ),
		Format::Lisp::Directive::C.new,
		Format::Lisp::Text.new( text => 'C' )
	];
	is-deeply $fl._parse( Q{^~^^} ), [
		Format::Lisp::Text.new( text => '^' ),
		Format::Lisp::Directive::Caret.new,
		Format::Lisp::Text.new( text => '^' )
	];
	is-deeply $fl._parse( Q{d~dd} ), [
		Format::Lisp::Text.new( text => 'd' ),
		Format::Lisp::Directive::D.new,
		Format::Lisp::Text.new( text => 'd' )
	];
	is-deeply $fl._parse( Q{D~DD} ), [
		Format::Lisp::Text.new( text => 'D' ),
		Format::Lisp::Directive::D.new,
		Format::Lisp::Text.new( text => 'D' )
	];
#`(
	is-deeply $fl._parse( Q{S~$$} ), [
		Format::Lisp::Text.new( text => Q{S} ),
		Format::Lisp::Directive::Dollar.new,
		Format::Lisp::Text.new( text => Q{S} )
	];
)
	is-deeply $fl._parse( Q{e~ee} ), [
		Format::Lisp::Text.new( text => 'e' ),
		Format::Lisp::Directive::E.new,
		Format::Lisp::Text.new( text => 'e' )
	];
	is-deeply $fl._parse( Q{E~EE} ), [
		Format::Lisp::Text.new( text => 'E' ),
		Format::Lisp::Directive::E.new,
		Format::Lisp::Text.new( text => 'E' )
	];
	is-deeply $fl._parse( Q{f~ff} ), [
		Format::Lisp::Text.new( text => 'f' ),
		Format::Lisp::Directive::F.new,
		Format::Lisp::Text.new( text => 'f' )
	];
	is-deeply $fl._parse( Q{F~FF} ), [
		Format::Lisp::Text.new( text => 'F' ),
		Format::Lisp::Directive::F.new,
		Format::Lisp::Text.new( text => 'F' )
	];
	is-deeply $fl._parse( Q{g~gg} ), [
		Format::Lisp::Text.new( text => 'g' ),
		Format::Lisp::Directive::G.new,
		Format::Lisp::Text.new( text => 'g' )
	];
	is-deeply $fl._parse( Q{G~GG} ), [
		Format::Lisp::Text.new( text => 'G' ),
		Format::Lisp::Directive::G.new,
		Format::Lisp::Text.new( text => 'G' )
	];
	is-deeply $fl._parse( Q{i~ii} ), [
		Format::Lisp::Text.new( text => 'i' ),
		Format::Lisp::Directive::I.new,
		Format::Lisp::Text.new( text => 'i' )
	];
	is-deeply $fl._parse( Q{I~II} ), [
		Format::Lisp::Text.new( text => 'I' ),
		Format::Lisp::Directive::I.new,
		Format::Lisp::Text.new( text => 'I' )
	];
	is-deeply $fl._parse( Q{o~oo} ), [
		Format::Lisp::Text.new( text => 'o' ),
		Format::Lisp::Directive::O.new,
		Format::Lisp::Text.new( text => 'o' )
	];
	is-deeply $fl._parse( Q{O~OO} ), [
		Format::Lisp::Text.new( text => 'O' ),
		Format::Lisp::Directive::O.new,
		Format::Lisp::Text.new( text => 'O' )
	];
	is-deeply $fl._parse( Q{p~pp} ), [
		Format::Lisp::Text.new( text => 'p' ),
		Format::Lisp::Directive::P.new,
		Format::Lisp::Text.new( text => 'p' )
	];
	is-deeply $fl._parse( Q{P~PP} ), [
		Format::Lisp::Text.new( text => 'P' ),
		Format::Lisp::Directive::P.new,
		Format::Lisp::Text.new( text => 'P' )
	];
	is-deeply $fl._parse( Q{(~(~))} ), [
		Format::Lisp::Text.new( text => '(' ),
		Format::Lisp::Directive::Paren.new,
		Format::Lisp::Text.new( text => ')' )
	];
	is-deeply $fl._parse( Q{)~(~)(} ), [
		Format::Lisp::Text.new( text => ')' ),
		Format::Lisp::Directive::Paren.new,
		Format::Lisp::Text.new( text => '(' )
	];
	is-deeply $fl._parse( Q{%~%%} ), [
		Format::Lisp::Text.new( text => '%' ),
		Format::Lisp::Directive::Percent.new,
		Format::Lisp::Text.new( text => '%' )
	];
	is-deeply $fl._parse( Q{|~||} ), [
		Format::Lisp::Text.new( text => '|' ),
		Format::Lisp::Directive::Pipe.new,
		Format::Lisp::Text.new( text => '|' )
	];
	is-deeply $fl._parse( Q{?~??} ), [
		Format::Lisp::Text.new( text => '?' ),
		Format::Lisp::Directive::Ques.new,
		Format::Lisp::Text.new( text => '?' )
	];
	is-deeply $fl._parse( Q{r~rr} ), [
		Format::Lisp::Text.new( text => 'r' ),
		Format::Lisp::Directive::R.new,
		Format::Lisp::Text.new( text => 'r' )
	];
	is-deeply $fl._parse( Q{R~RR} ), [
		Format::Lisp::Text.new( text => 'R' ),
		Format::Lisp::Directive::R.new,
		Format::Lisp::Text.new( text => 'R' )
	];
	is-deeply $fl._parse( Q{s~ss} ), [
		Format::Lisp::Text.new( text => 's' ),
		Format::Lisp::Directive::S.new,
		Format::Lisp::Text.new( text => 's' )
	];
	is-deeply $fl._parse( Q{S~SS} ), [
		Format::Lisp::Text.new( text => 'S' ),
		Format::Lisp::Directive::S.new,
		Format::Lisp::Text.new( text => 'S' )
	];
	is-deeply $fl._parse( Q{;~;;} ), [
		Format::Lisp::Text.new( text => ';' ),
		Format::Lisp::Directive::Semi.new,
		Format::Lisp::Text.new( text => ';' )
	];
	is-deeply $fl._parse( Q{/~/a//} ), [
		Format::Lisp::Text.new( text => '/' ),
		Format::Lisp::Directive::Slash.new(
			text => 'a'
		),
		Format::Lisp::Text.new( text => '/' )
	];
	is-deeply $fl._parse( Q{*~**} ), [
		Format::Lisp::Text.new( text => '*' ),
		Format::Lisp::Directive::Star.new,
		Format::Lisp::Text.new( text => '*' )
	];
	is-deeply $fl._parse( Q{t~tt} ), [
		Format::Lisp::Text.new( text => 't' ),
		Format::Lisp::Directive::T.new,
		Format::Lisp::Text.new( text => 't' )
	];
	is-deeply $fl._parse( Q{T~TT} ), [
		Format::Lisp::Text.new( text => 'T' ),
		Format::Lisp::Directive::T.new,
		Format::Lisp::Text.new( text => 'T' )
	];
#`(
	is-deeply $fl._parse( Q{\~~~} ), [
		Format::Lisp::Text.new( text => '~' ),
		Format::Lisp::Directive::Tilde.new
	];
)
	is-deeply $fl._parse( Q{_~__} ), [
		Format::Lisp::Text.new( text => '_' ),
		Format::Lisp::Directive::Under.new,
		Format::Lisp::Text.new( text => '_' )
	];
	is-deeply $fl._parse( Q{w~ww} ), [
		Format::Lisp::Text.new( text => 'w' ),
		Format::Lisp::Directive::W.new,
		Format::Lisp::Text.new( text => 'w' )
	];
	is-deeply $fl._parse( Q{W~WW} ), [
		Format::Lisp::Text.new( text => 'W' ),
		Format::Lisp::Directive::W.new,
		Format::Lisp::Text.new( text => 'W' )
	];
	is-deeply $fl._parse( Q{x~xx} ), [
		Format::Lisp::Text.new( text => 'x' ),
		Format::Lisp::Directive::X.new,
		Format::Lisp::Text.new( text => 'x' )
	];
	is-deeply $fl._parse( Q{X~XX} ), [
		Format::Lisp::Text.new( text => 'X' ),
		Format::Lisp::Directive::X.new,
		Format::Lisp::Text.new( text => 'X' )
	];

	done-testing;
		
}, 'Atom with text tricks';

subtest {
	is-deeply $fl._parse( Q{~:A} ), [
		Format::Lisp::Directive::A.new(
			colon => True
		)
	];
	is-deeply $fl._parse( Q{~@A} ), [
		Format::Lisp::Directive::A.new(
			at => True
		)
	];
	is-deeply $fl._parse( Q{~:@A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True
		)
	];
	is-deeply $fl._parse( Q{~@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True
		)
	];

	subtest {
		is-deeply $fl._parse( Q{~:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				colon => True
			)
		];
		is-deeply $fl._parse( Q{~@<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True
			)
		];
		is-deeply $fl._parse( Q{~:@<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True
			)
		];
		is-deeply $fl._parse( Q{~@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True
			)
		];
		is-deeply $fl._parse( Q{~<~:>} ), [
			Format::Lisp::Directive::Angle.new(
				trailing-colon => True
			)
		];
		is-deeply $fl._parse( Q{~:<~:>} ), [
			Format::Lisp::Directive::Angle.new(
				colon => True,
				trailing-colon => True
			)
		];

		done-testing;
		
	}, 'balanced directive';

	done-testing;
		
}, 'options';

subtest {
	is-deeply $fl._parse( Q{~vA} ), [
		Format::Lisp::Directive::A.new(
			mincol => 'next'
		)
	];
	is-deeply $fl._parse( Q{~VA} ), [
		Format::Lisp::Directive::A.new(
			mincol => 'next'
		)
	];
	is-deeply $fl._parse( Q{~#A} ), [
		Format::Lisp::Directive::A.new(
			mincol => 'remaining'
		)
	];
	is-deeply $fl._parse( Q{~-2A} ), [
		Format::Lisp::Directive::A.new(
			mincol => -2
		)
	];
	is-deeply $fl._parse( Q{~-1A} ), [
		Format::Lisp::Directive::A.new(
			mincol => -1
		)
	];
	is-deeply $fl._parse( Q{~-0A} ), [
		Format::Lisp::Directive::A.new(
			mincol => 0
		)
	];
	is-deeply $fl._parse( Q{~0A} ), [
		Format::Lisp::Directive::A.new(
			mincol => 0
		)
	];
	is-deeply $fl._parse( Q{~+0A} ), [
		Format::Lisp::Directive::A.new(
			mincol => 0
		)
	];
	is-deeply $fl._parse( Q{~+1A} ), [
		Format::Lisp::Directive::A.new(
			mincol => 1
		)
	];
	is-deeply $fl._parse( Q{~+2A} ), [
		Format::Lisp::Directive::A.new(
			mincol => 2
		)
	];
	is-deeply $fl._parse( Q{~'*A} ), [
		Format::Lisp::Directive::A.new(
			mincol => Q{*}
		)
	];
	is-deeply $fl._parse( Q{~'AA} ), [
		Format::Lisp::Directive::A.new(
			mincol => Q{A}
		)
	];
	is-deeply $fl._parse( Q{~'aa} ), [
		Format::Lisp::Directive::A.new(
			mincol => Q{a}
		)
	];
#`(
	is-deeply $fl._parse( Q{~'#a} ), [
		Format::Lisp::Directive::A.new(
			arguments => [ Q{#} ]
		)
	];
)
	is-deeply $fl._parse( Q{~'va} ), [
		Format::Lisp::Directive::A.new(
			mincol => Q{v}
		)
	];
	is-deeply $fl._parse( Q{~'Va} ), [
		Format::Lisp::Directive::A.new(
			mincol => Q{V}
		)
	];
	is-deeply $fl._parse( Q{~',A} ), [
		Format::Lisp::Directive::A.new(
			mincol => Q{,}
		)
	];
#`(
	is-deeply $fl._parse( Q{~'\'A} ), [
		Format::Lisp::Directive::A.new(
			arguments => [ Q{'} ]
		)
	];
)

	subtest {
		is-deeply $fl._parse( Q{~v<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ 'next' ]
			)
		];
		is-deeply $fl._parse( Q{~V<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ 'next' ]
			)
		];
		is-deeply $fl._parse( Q{~#<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ 'remaining' ]
			)
		];
		is-deeply $fl._parse( Q{~-2<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ -2 ]
			)
		];
		is-deeply $fl._parse( Q{~-1<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ -1 ]
			)
		];
		is-deeply $fl._parse( Q{~-0<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ 0 ]
			)
		];
		is-deeply $fl._parse( Q{~0<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ 0 ]
			)
		];
		is-deeply $fl._parse( Q{~+0<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ 0 ]
			)
		];
		is-deeply $fl._parse( Q{~+1<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ 1 ]
			)
		];
		is-deeply $fl._parse( Q{~+2<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ 2 ]
			)
		];
		is-deeply $fl._parse( Q{~'*<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ Q{*} ]
			)
		];
		is-deeply $fl._parse( Q{~'A<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ Q{A} ]
			)
		];
		is-deeply $fl._parse( Q{~'a<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ Q{a} ]
			)
		];
#`(
		is-deeply $fl._parse( Q{~'#<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ Q{#} ]
			)
		];
)
		is-deeply $fl._parse( Q{~'v<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ Q{v} ]
			)
		];
		is-deeply $fl._parse( Q{~'V<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ Q{V} ]
			)
		];
		is-deeply $fl._parse( Q{~',<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ Q{,} ]
			)
		];
#`(
		is-deeply $fl._parse( Q{~'\'<~>} ), [
			Format::Lisp::Directive::Angle.new(
				arguments => [ Q{'} ]
			)
		];
)

		done-testing;
			
	}, 'balanced directives';

	done-testing;
		
}, 'single argument';

subtest {
	is-deeply $fl._parse( Q{~v@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => 'next'
		)
	];
	is-deeply $fl._parse( Q{~V@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => 'next'
		)
	];
	is-deeply $fl._parse( Q{~#@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => 'remaining'
		)
	];
	is-deeply $fl._parse( Q{~-2@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => -2
		)
	];
	is-deeply $fl._parse( Q{~-1@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => -1
		)
	];
	is-deeply $fl._parse( Q{~-0@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => 0
		)
	];
	is-deeply $fl._parse( Q{~0@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => 0
		)
	];
	is-deeply $fl._parse( Q{~+0@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => 0
		)
	];
	is-deeply $fl._parse( Q{~+1@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => 1
		)
	];
	is-deeply $fl._parse( Q{~+2@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => 2
		)
	];
#`(
	is-deeply $fl._parse( Q{~'@@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True
		)
	];
)
	is-deeply $fl._parse( Q{~'A@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => Q{A}
		)
	];
	is-deeply $fl._parse( Q{~'a@:a} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => Q{a}
		)
	];
#`(
	is-deeply $fl._parse( Q{~'#@:a} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => Q{'#}
		)
	];
)
	is-deeply $fl._parse( Q{~'v@:a} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => Q{v}
		)
	];
	is-deeply $fl._parse( Q{~'V@:a} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => Q{V}
		)
	];
	is-deeply $fl._parse( Q{~',@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => Q{,}
		)
	];
#`(
	is-deeply $fl._parse( Q{~'\'@:A} ), [
		Format::Lisp::Directive::A.new(
			at => True,
			colon => True,
			mincol => Q{''}
		)
	];
)

	subtest {
		is-deeply $fl._parse( Q{~v@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => 'next',
				arguments => [ 'next' ]
			)
		];
		is-deeply $fl._parse( Q{~V@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => 'next',
				arguments => [ 'next' ]
			)
		];
		is-deeply $fl._parse( Q{~#@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => 'remaining',
				arguments => [ 'remaining' ]
			)
		];
		is-deeply $fl._parse( Q{~-2@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => -2,
				arguments => [ -2 ]
			)
		];
		is-deeply $fl._parse( Q{~-1@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => -1,
				arguments => [ -1 ]
			)
		];
		is-deeply $fl._parse( Q{~-0@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => 0,
				arguments => [ 0 ]
			)
		];
		is-deeply $fl._parse( Q{~0@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => 0,
				arguments => [ 0 ]
			)
		];
		is-deeply $fl._parse( Q{~+0@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => 0,
				arguments => [ 0 ]
			)
		];
		is-deeply $fl._parse( Q{~+1@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => 1,
				arguments => [ 1 ]
			)
		];
		is-deeply $fl._parse( Q{~+2@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => 2,
				arguments => [ 2 ]
			)
		];
		is-deeply $fl._parse( Q{~'*@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => Q{*},
				arguments => [ Q{*} ]
			)
		];
		is-deeply $fl._parse( Q{~'A@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => Q{A},
				arguments => [ Q{A} ]
			)
		];
		is-deeply $fl._parse( Q{~'a@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => Q{a},
				arguments => [ Q{a} ]
			)
		];
#`(
		is-deeply $fl._parse( Q{~'#@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => Q{'#},
				arguments => [ Q{'#} ]
			)
		];
)
		is-deeply $fl._parse( Q{~'v@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => Q{v},
				arguments => [ Q{v} ]
			)
		];
		is-deeply $fl._parse( Q{~'V@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => Q{V},
				arguments => [ Q{V} ]
			)
		];
		is-deeply $fl._parse( Q{~',@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => Q{,},
				arguments => [ Q{,} ]
			)
		];
#`(
		is-deeply $fl._parse( Q{~'\'@:<~>} ), [
			Format::Lisp::Directive::Angle.new(
				at => True,
				colon => True,
				mincol => Q{''},
				arguments => [ Q{''} ]
			)
		];
)

		done-testing;
			
	}, 'balanced directives';

	done-testing;
		
}, 'single argument with options';

subtest {
	subtest {
		is-deeply $fl._parse( Q{~,A} ), [
			Format::Lisp::Directive::A.new(
			)
		];
		is-deeply $fl._parse( Q{~,vA} ), [
			Format::Lisp::Directive::A.new(
				colinc => 'next'
			)
		];
		is-deeply $fl._parse( Q{~,#A} ), [
			Format::Lisp::Directive::A.new(
				colinc => 'remaining'
			)
		];
		is-deeply $fl._parse( Q{~,0A} ), [
			Format::Lisp::Directive::A.new(
				colinc => 0
			)
		];

		done-testing;
	}, 'blank first argument';

	subtest {
		is-deeply $fl._parse( Q{~v,A} ), [
			Format::Lisp::Directive::A.new(
				mincol => 'next'
			)
		];
		is-deeply $fl._parse( Q{~v,vA} ), [
			Format::Lisp::Directive::A.new(
				mincol => 'next',
				colinc => 'next'
			)
		];
		is-deeply $fl._parse( Q{~v,#A} ), [
			Format::Lisp::Directive::A.new(
				mincol => 'next',
				colinc => 'remaining'
			)
		];
		is-deeply $fl._parse( Q{~v,0A} ), [
			Format::Lisp::Directive::A.new(
				mincol => 'next',
				colinc => 0
			)
		];

		done-testing;
	}, 'first argument "v"';

	subtest {
		is-deeply $fl._parse( Q{~#,A} ), [
			Format::Lisp::Directive::A.new(
				mincol => 'remaining'
			)
		];
		is-deeply $fl._parse( Q{~#,vA} ), [
			Format::Lisp::Directive::A.new(
				mincol => 'remaining',
				colinc => 'next'
			)
		];
		is-deeply $fl._parse( Q{~#,#A} ), [
			Format::Lisp::Directive::A.new(
				mincol => 'remaining',
				colinc => 'remaining'
			)
		];
		is-deeply $fl._parse( Q{~#,0A} ), [
			Format::Lisp::Directive::A.new(
				mincol => 'remaining',
				colinc => 0
			)
		];

		done-testing;
	}, 'first argument "#"';

	subtest {
		is-deeply $fl._parse( Q{~0,A} ), [
			Format::Lisp::Directive::A.new(
				mincol => 0
			)
		];
		is-deeply $fl._parse( Q{~0,vA} ), [
			Format::Lisp::Directive::A.new(
				mincol => 0,
				colinc => 'next'
			)
		];
		is-deeply $fl._parse( Q{~0,#A} ), [
			Format::Lisp::Directive::A.new(
				mincol => 0,
				colinc => 'remaining'
			)
		];
		is-deeply $fl._parse( Q{~0,0A} ), [
			Format::Lisp::Directive::A.new(
				mincol => 0,
				colinc => 0
			)
		];

		done-testing;
	}, 'first argument 0, XXX bogus';

	subtest {
		is-deeply $fl._parse( Q{~'*,A} ), [
			Format::Lisp::Directive::A.new(
				mincol => Q{*},
				colinc => 1
			)
		];
		is-deeply $fl._parse( Q{~'*,vA} ), [
			Format::Lisp::Directive::A.new(
				mincol => Q{*},
				colinc => 'next'
			)
		];
		is-deeply $fl._parse( Q{~'*,#A} ), [
			Format::Lisp::Directive::A.new(
				mincol => Q{*},
				colinc => 'remaining'
			)
		];
		is-deeply $fl._parse( Q{~'*,0A} ), [
			Format::Lisp::Directive::A.new(
				mincol => Q{*},
				colinc => 0
			)
		];

		done-testing;
	}, Q{first argument '* XXX bogus};

	done-testing;
		
}, 'multiple mixed arguments';

subtest {
	is-deeply $fl._parse( Q{~<~<~>~>} ), [
		Format::Lisp::Directive::Angle.new(
			children => [
				Format::Lisp::Directive::Angle.new
			]
		)
	];
	is-deeply $fl._parse( Q{~<~{~}~>} ), [
		Format::Lisp::Directive::Angle.new(
			children => [
				Format::Lisp::Directive::Brace.new
			]
		)
	];
	is-deeply $fl._parse( Q{~<~[~]~>} ), [
		Format::Lisp::Directive::Angle.new(
			children => [
				Format::Lisp::Directive::Bracket.new
			]
		)
	];
	is-deeply $fl._parse( Q{~<~(~)~>} ), [
		Format::Lisp::Directive::Angle.new(
			children => [
				Format::Lisp::Directive::Paren.new
			]
		)
	];

	done-testing;
		
}, 'nest balanced directive';

done-testing;

# vim: ft=perl6
