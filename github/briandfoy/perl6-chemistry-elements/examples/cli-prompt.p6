use v6;
use Chemistry::Elements;

say "This is a simplistic example for the 'Chemistry' module.\n";

# This has an entry for each item in the user menu.
# The position in @options is the position in the menu
# The first element of each item is a string noting the conversion
# The second item is a lambda that does the conversion
my @options = [
	[
	'Exit!',
	-> Str $n { exit; },
	],
	[
	'atomic number -> name',
	-> ZInt $n { Chemistry::Elements.get_name_by_Z( $n ) },
	],
	[
	'symbol        -> name',
	-> ChemicalSymbol $n { Chemistry::Elements.get_name_by_symbol( $n ) },
	],
	[
	'atomic number -> symbol',
	-> ZInt $n { Chemistry::Elements.get_symbol_by_Z( $n ) },
	],
	[
	'name          -> symbol',
	-> Str $n { Chemistry::Elements.get_symbol_by_name( $n ) },
	],
	[
	'name          -> atomic number (Warning: not yet implemented!)',
	-> Str $n { 'Not yet implemented!' },
	],
	[
	'symbol        -> atomic number',
	-> ChemicalSymbol $n { Chemistry::Elements.get_Z_by_symbol( $n ) },
	]
];


loop {
	say q:heredoc/END/;
Please choose:
	0: Exit!
	1: atomic number -> name
	2: symbol        -> name
	3: atomic number -> symbol
	4: name          -> symbol
	5: name          -> atomic number (Warning: not yet implemented!)
	6: symbol        -> atomic number
END

    my $mode = prompt("Choose a mode> ");
	exit unless $mode > 0;

	# get the label and turn it into the secondary prompt
    my $prompt_string = @options[$mode][0];
	$prompt_string ~~ s/ \s+ \-\> .* //;

	try {
		CATCH {
			when X::TypeCheck {
				say "Inappropriate input. Try again";
				}
			default { .Str.say; }
			}

		my $input = prompt("Enter the $prompt_string > ");

		say @options[$mode][1]($input) ~ "\n";
		}
    }
