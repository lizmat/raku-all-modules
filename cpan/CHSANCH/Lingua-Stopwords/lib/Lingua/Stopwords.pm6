use v6.c;

unit module Lingua::Stopwords;

sub get-stopwords ( Str $language = 'en', Str $list = 'snowball' --> SetHash ) is export {
    
    my $module-name = 'Lingua::Stopwords::' ~ $language.uc;
    
    try require ::($module-name) <&get-list>;
    
    if ::($module-name) ~~ Failure {
        fail 'Failed to load ' ~ $module-name ~ '. Are you sure \'' ~ $language ~ '\' is a valid language ISO code? ';
    }
    
    my $stop-words = get-list( $list.lc );
    
    return $stop-words;
}