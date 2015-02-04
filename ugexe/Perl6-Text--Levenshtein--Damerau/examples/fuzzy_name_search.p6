use v6;
use Text::Levenshtein::Damerau;

my Str @names = ( 
	'Angela Smarts',
	'Angela Sharron',
	'Andrew North',
	'Andy North',
	'Andy Norths',
	'Ameila Anderson',
);

say "[NAMES]: {@names.join(',')}";
say "Enter a name to fuzzy search against: ";
my Str $fuzzy_name = $*IN.get;

my Str $best_match = "";
my Int $best_distance;

for @names -> Str $name {
	my Int $distance = edistance($fuzzy_name,$name);
	say "*$name - $distance";

	if ( !$best_distance || ( $distance >= 0 && $distance < $best_distance ) ) {
		$best_match = $name;
		$best_distance = $distance;
	}
}

say "\nDamerau-Levenshtein search result: $best_match with a distance of $best_distance";