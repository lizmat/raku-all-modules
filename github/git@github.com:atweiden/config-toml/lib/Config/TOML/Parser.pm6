use v6;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;
unit class Config::TOML::Parser;

method parse(Str:D $content, *%opts (Int :date-local-offset($)) --> Match:D)
{
    my Config::TOML::Parser::Actions $actions .= new(|%opts);
    Config::TOML::Parser::Grammar.parse($content, :$actions);
}

method parsefile(Str:D $file, *%opts (Int :date-local-offset($)) --> Match:D)
{
    my Config::TOML::Parser::Actions $actions .= new(|%opts);
    Config::TOML::Parser::Grammar.parsefile($file, :$actions);
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
