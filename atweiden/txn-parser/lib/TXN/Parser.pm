use v6;
use TXN::Parser::Actions;
use TXN::Parser::Grammar;
use X::TXN::Parser;
unit class TXN::Parser;

method parse(Str:D $content, *%opts (Int :$date-local-offset)) returns Match
{
    my TXN::Parser::Actions $actions .= new(|%opts);
    my Str:D $journal = preprocess($content);
    TXN::Parser::Grammar.parse($journal, :$actions)
        or die X::TXN::Parser::ParseFailed.new;
}

method parsefile(Str:D $file, *%opts (Int :$date-local-offset)) returns Match
{
    my TXN::Parser::Actions $actions .= new(|%opts);
    my Str:D $journal = preprocess(:$file);
    TXN::Parser::Grammar.parse($journal, :$actions)
        or die X::TXN::Parser::ParsefileFailed.new;
}

multi sub preprocess(Str:D $content) returns Str:D
{
    resolve-includes($content);
}

multi sub preprocess(Str:D :$file!) returns Str:D
{
    resolve-includes(slurp($file), :$file);
}

sub resolve-includes(Str:D $journal-orig, Str:D :$file = '.') returns Str:D
{
    my Str:D $journal = "";

    for $journal-orig.lines -> $line
    {
        # is it an include line?
        if TXN::Parser::Grammar.parse(
            "$line\n",
            :actions(TXN::Parser::Actions),
            :rule<include-line>
        )
        {
            my Str $filename = join('/', $file.IO.dirname, $/.made);
            unless $filename.IO.e && $filename.IO.r
            {
                die X::TXN::Parser::Include.new(:$filename);
            }
            $journal ~= preprocess(:file($filename));
        }
        else
        {
            $journal ~= $line ~ "\n";
        }
    }

    $journal;
}

# vim: ft=perl6
