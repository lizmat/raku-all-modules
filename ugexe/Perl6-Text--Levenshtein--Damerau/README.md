# NAME

Text::Levenshtein::Damerau - Levenshtein and Damerau Levenshtein edit distances.

# SYNOPSIS

    use Text::Levenshtein::Damerau;

    say dld('Neil','Niel'); # damerau levenstein distance
    # prints 1

    say ld('Neil','Niel'); # levenshtein distance
    prints 2

# DESCRIPTION

Returns the true Levenshtein or Damerau Levenshtein edit distance of strings with adjacent transpositions. 

    use Text::Levenshtein::Damerau;

    my @names = 'John','Jonathan','Jose','Juan','Jimmy';
    my $name_mispelling = 'Jonh';

    my $dl = Text::Levenshtein::Damerau.new(
        max             => 0,       # default 
        targets         => @names,  # required
    );

    say "Lets search for a 'John' but mistyped...";
    $dl.get_results(source => $name_mispelling);

    my %results = $dl.results;

    # Display each string and is distance
    say "DISTANCE\tSTRING";
    for %results.kv -> $string,$info {
        say "{{$info<distance>}\t\t$string\n";
    }

    # More info
    say "----------------------------";
    say "\$dl.best_distance:        {$dl.best_distance}";
    say "-";
    say "\$dl.targets:              {~$dl.targets}";
    say "\$dl.best_target:          {$dl.best_target}";
    say "-";
    say "\@names:                   {~@names}";

# METHODS

## dld

Damerau Levenshtein Distance (Levenshtein Distance including transpositions)

Arguments: source string and target string.

- _OPTIONAL 3rd argument_ int $max distance. Nil/-1 = unlimited. Default = Nil. 

Returns: int that represents the edit distance between the two argument. Stops calculations and returns Inf if max distance is set and reached if possible.


    use Text::Levenshtein::Damerau;
    say dld('AABBCC','AABCBCD');
    # prints 2

    # Max edit distance of 1
    say dld('AABBCC','AABCBCD',1); # distance is 2
    # prints Nil

## ld

Levenshtein Distance (no transpositions)

Arguments: source string and target string.

- _OPTIONAL 3rd argument_ int $max distance. Nil/-1 = unlimited. Default = Nil. 

Returns: int that represents the edit distance between the two argument. Stops calculations and returns Inf if max distance is set and reached if possible.

    use Text::Levenshtein::Damerau;
    say ld('AABBCC','AABCBCD');
    # prints 3

    # Max edit distance of 1
    # Uses regular Levenshtein distance (no transpositions)
    say ld('AABBCC','AABCBCD',1); # distance is 3
    # prints Nil

# BUGS

Please report bugs to:

[https://github.com/ugexe/Perl6-Text--Levenshtein--Damerau/issues](https://github.com/ugexe/Perl6-Text--Levenshtein--Damerau/issues)

# AUTHOR

Nick Logan <`ugexe@cpan.org`\>
