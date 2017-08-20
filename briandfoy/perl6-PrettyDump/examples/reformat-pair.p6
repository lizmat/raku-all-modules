#!/Applications/Rakudo/bin/perl6

#`(
This is an example of overriding some core handlers to format a data
structure any way that you like.

It's likely that PrettyDump formatting will change without
corresponding updates to this example.
)

my $hash = %(
	Hamadryas => 'Cracker',
	Danaus    => 'Monarch',
	Papilio   => 'Swallowtail',
	Boolean   => True,
	Nested    => %(
		cat => 1,
		lizard => 3,
		platypus => 17,
		),
	);

# Here's the builtin dumper
dd $hash;


#`(
Now try it with the regular PrettyDump handlers. This is what you get:

	Hash={
		:Boolean,
		:Danaus("Monarch"),
		:Hamadryas("Cracker"),
		:Nested(Hash={
			:cat(1),
			:lizard(3),
			:platypus(17)
		}),
		:Papilio("Swallowtail")
)
use lib qw<lib>;
use PrettyDump;
my $pretty = PrettyDump.new;
say $pretty.dump: $hash;

#`(
Replace the Hash handler to line up the arrows

	｢Papilio｣   => "Swallowtail",
	｢Danaus｣    => "Monarch",
	｢Boolean｣   => True,
	｢Hamadryas｣ => "Cracker",
	｢Nested｣    =>
		｢cat｣      => 1,
		｢platypus｣ => 17,
		｢lizard｣   => 3
)

my $pair-code = -> PrettyDump $pretty, $ds, Int:D :$depth = 0 --> Str {
	[~]
		'｢', $ds.key, '｣',
		' => ',
		$pretty.dump: $ds.value, :depth(0)

	};

my $hash-code = -> PrettyDump $pretty, $ds, Int:D :$depth = 0 --> Str {
	my $longest-key = $ds.keys.max: *.chars;
	my $template = "%-{2+$depth+1+$longest-key.chars}s => %s";

	my $str = do {
		if @($ds).keys {
			my $separator = [~] $pretty.pre-separator-spacing, ',', $pretty.post-separator-spacing;
			[~]
				$pretty.pre-item-spacing,
				join( $separator,
					grep { $_ ~~ Str:D },
					map {
						/^ \t* '｢' .*? '｣' \h+ '=>' \h+/
							??
						sprintf( $template, .split: / \h+ '=>' \h+  /, 2 )
							!!
						$_
						},
					map { $pretty.dump: $_, :depth($depth+1) }, $ds.pairs
					),
				$pretty.post-item-spacing;
			}
		else {
			$pretty.intra-group-spacing;
			}
		}

	"Hash=\{$str\t}"
	}

$pretty.add-handler: 'Pair', $pair-code;
$pretty.add-handler: 'Hash', $hash-code;

say $pretty.dump: $hash;
