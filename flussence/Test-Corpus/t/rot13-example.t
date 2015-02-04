use v6;
use Test::Corpus;

sub rot13(Str $in) {
    $in.trans('a'..'z' => ['n'..'z', 'a'..'m'])\
       .trans('A'..'Z' => ['N'..'Z', 'A'..'M']);
}

run-tests(simple-test(&rot13));
