use v6;
use Test;
plan 4;
use Text::Levenshtein::Damerau;


{
    my @names = 'John','Jonathan','Jose','Juan','Jimmy';
    my $name_mispelling = 'Jonh';

    my $dl = Text::Levenshtein::Damerau.new( sources => [$name_mispelling], targets => @names );
    $dl.get_results;
    
    my %results = $dl.results;

    is( $dl.best_target, 'John',                    'test $dl.best_target manually');
    is( $dl.best_distance, 1,                       'test $dl.best_distance');
    is( %results<John><distance>, 1,                'test .results distance');
    is( %results<Jose><distance>, 2,                'test .results distance again');
}
