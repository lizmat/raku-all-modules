use v6;
use TXN::Parser::Actions;
use TXN::Parser::Grammar;
unit class TXN::Parser;

method parse(Str:D $content, Int :$date-local-offset, Bool :$json) returns Match
{
    my %a;
    %a<date-local-offset> = $date-local-offset if $date-local-offset;
    %a<json> = $json if $json;

    my TXN::Parser::Actions $actions .= new(|%a);
    TXN::Parser::Grammar.parse($content, :$actions);
}

method parsefile(Str:D $file, Int :$date-local-offset, Bool :$json) returns Match
{
    my %a;
    %a<date-local-offset> = $date-local-offset if $date-local-offset;
    %a<json> = $json if $json;

    my TXN::Parser::Actions $actions .= new(|%a);
    TXN::Parser::Grammar.parsefile($file, :$actions);
}

multi method preprocess(Str:D $content) returns Str:D
{
    self!resolve-includes($content);
}

multi method preprocess(Str:D :$file!) returns Str:D
{
    self!resolve-includes(slurp $file);
}

method !resolve-includes(Str:D $journal-orig) returns Str:D
{
    my Str:D $journal = "";
    for $journal-orig.lines -> $line
    {
        $journal ~= TXN::Parser::Grammar.parse(
            "$line\n",
            :actions(TXN::Parser::Actions),
            :rule<include-line>
        ) ?? self.preprocess(:file($/.made)) !! $line ~ "\n";
    }
    $journal;
}

# vim: ft=perl6
