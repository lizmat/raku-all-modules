# Algorithm::Soundex - Soundex Algorithms in Perl 6

    use v6;
    use Algorithm::Soundex;

    my Algorithm::Soundex $s .= new();
    my $soundex               = $s.soundex("Leto");
    say "The soundex of Leto is $soundex";

## Running Tests

    $ prove -e "perl6 -Ilib" -r t/
