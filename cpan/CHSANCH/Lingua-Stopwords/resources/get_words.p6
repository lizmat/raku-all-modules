use v6.c;

sub MAIN(Str :$language!, *@files) {
    say "Creating file for language: " ~ $language;
    my %words;
    for @files -> $f {
        say "opening " ~ $f;
        for $f.IO.lines -> $line {
            $line.chomp;
            %words{$line} = 1;
        }  
    }
    say %words.keys.elems;

    my $new-file = $language ~ ".txt";
    my $fh = open $new-file, :w;
    for %words.keys.sort -> $word {
        $fh.say($word);
    }
    $fh.close;
}