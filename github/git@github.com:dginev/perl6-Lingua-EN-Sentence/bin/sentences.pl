use v6;
use Lingua::EN::Sentence;

sub MAIN(Str $in, Str $out) {
    my $text = slurp $in;
    my @sentences = $text.sentences;
    my $fh = open $out, :w;
    $fh.print(@sentences.join("\n-----\n"));
    $fh.close;
}
