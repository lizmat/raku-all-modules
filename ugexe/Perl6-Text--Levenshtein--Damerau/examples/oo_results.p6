use v6;
use Text::Levenshtein::Damerau;

my @names = 'John','Jonathan','Jose','Juan','Jimmy';
my $name_mispelling = 'Jonh';

my $dl = Text::Levenshtein::Damerau.new(
#	max_distance	=> 10, 
	targets			=> @names,
);

say "Lets search for a 'John' but mistyped...";
$dl.get_results(source => $name_mispelling);

# ex. %results<string> = {index => #, distance => #}
my %results = $dl.results;

# Display each string and is distance
say "INDEX\t\tDISTANCE\tSTRING";
for %results.kv -> $string,$info {
    say "{$info<index>}\t\t{$info<distance>}\t\t$string\n";
}

# Show various attributes
say "----------------------------";
say "\$dl.best_distance:        {$dl.best_distance}";
say "\$dl.best_index:           {$dl.best_index}";
say "-";
say "\$dl.targets:              {~$dl.targets}";
say "\$dl.best_target:          {$dl.best_target}";
say "-";
say "\@names:                   {~@names}";
say "\@names[\$dl.best_index]    {@names[$dl.best_index]}";

