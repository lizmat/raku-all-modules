use v6;
use Test::Corpus;

sub rot13(Str $in --> Str) {
    $in.trans('A..Z' => 'N..ZA..M')\
       .trans('a..z' => 'n..za..m');
}

run-tests(&rot13);
