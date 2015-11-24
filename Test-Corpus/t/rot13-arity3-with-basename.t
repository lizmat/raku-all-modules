use v6;
use Test::Corpus;
use Test;

sub rot13(IO::Path $in, IO::Path $out, Str $basename) {
    is $in.slurp\
          .trans('A..Z' => 'N..ZA..M')\
          .trans('a..z' => 'n..za..m'),
       $out.slurp,
       $basename;
}

run-tests(&rot13, :basename<rot13-example.t>);
