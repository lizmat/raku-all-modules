use v6;
use Text::Levenshtein::Damerau;

use Test;
plan 1;

lives-ok {

    my @names = 'John','Jonathan','Jose','Juan','Jimmy';
    my $name_mispelling = 'Jonh';

    my $dl = Text::Levenshtein::Damerau.new(
        max             => 0,       # default 
        targets         => @names,  # required
        sources         => [$name_mispelling]
    );

    say "Lets search for a 'John' but mistyped...";
    my %results =  $dl.get_results;

    # Display each source, target, and the distance
    for %results.kv -> $source, $targets {
        for $targets.kv -> $target, $dld {
            say "source:$source\ttarget:$target\tdld:" ~ ($dld // "<max exceeded>");
        }
    }

    # More info
    say "----------------------------";
    say "\$dl.best_distance:        {$dl.best_distance}";
    say "-";
    say "\$dl.targets:              {~$dl.targets}";
    say "\$dl.best_target:          {$dl.best_target}";
    say "-";
    say "\@names:                   {~@names}";
}, 'synopsis';