use v6;
use TXN::Parser::Actions;
use TXN::Parser::Grammar;
use X::TXN::Parser;
unit class TXN::Parser;

method parse(
    Str:D $content,
    *%opts (
        Int :$date-local-offset,
        Str :$txn-dir
    )
) returns Match
{
    my TXN::Parser::Actions $actions .= new(|%opts);
    TXN::Parser::Grammar.parse($content, :$actions)
        or die X::TXN::Parser::ParseFailed.new(:$content);
}

method parsefile(
    Str:D $file,
    *%opts (
        Int :$date-local-offset,
        Str :$txn-dir
    )
) returns Match
{
    my TXN::Parser::Actions $actions .= new(:$file, |%opts);
    TXN::Parser::Grammar.parsefile($file, :$actions)
        or die X::TXN::Parser::ParsefileFailed.new(:$file);
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
