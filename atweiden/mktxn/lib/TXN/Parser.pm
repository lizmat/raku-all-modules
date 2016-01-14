use v6;
use TXN::Parser::Actions;
use TXN::Parser::Grammar;
unit class TXN::Parser;

method parse(
    Str:D $content,
    Int :$date_local_offset,
    Bool :$json,
    *%opts
) returns Match
{
    my %a;
    %a<date_local_offset> = $date_local_offset if $date_local_offset;
    %a<json> = $json if $json;

    my TXN::Parser::Actions $actions .= new(|%a);
    TXN::Parser::Grammar.parse($content, :$actions, |%opts);
}

method parsefile(
    Str:D $file,
    Int :$date_local_offset,
    Bool :$json,
    *%opts
) returns Match
{
    my %a;
    %a<date_local_offset> = $date_local_offset if $date_local_offset;
    %a<json> = $json if $json;

    my TXN::Parser::Actions $actions .= new(|%a);
    TXN::Parser::Grammar.parsefile($file, :$actions, |%opts);
}

multi method preprocess(Str:D $content) returns Str:D
{
    self!resolve_includes($content);
}

multi method preprocess(Str:D :$file!) returns Str:D
{
    self!resolve_includes(slurp $file);
}

method !resolve_includes(Str:D $journal_orig) returns Str:D
{
    my Str:D $journal = "";
    for $journal_orig.lines -> $line
    {
        $journal ~= TXN::Parser::Grammar.parse(
            "$line\n",
            :actions(TXN::Parser::Actions),
            :rule<include_line>
        ) ?? self.preprocess(:file($/.made)) !! $line ~ "\n";
    }
    $journal;
}

# vim: ft=perl6
