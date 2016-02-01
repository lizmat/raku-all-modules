use v6;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;
unit class Config::TOML::Parser;

method parse(Str:D $content, Int :$date-local-offset, *%opts) returns Match
{
    my Config::TOML::Parser::Actions $actions .= new(:$date-local-offset);
    Config::TOML::Parser::Grammar.parse($content, :$actions, |%opts);
}

method parsefile(Str:D $file, Int :$date-local-offset, *%opts) returns Match
{
    my Config::TOML::Parser::Actions $actions .= new(:$date-local-offset);
    Config::TOML::Parser::Grammar.parsefile($file, :$actions, |%opts);
}

# vim: ft=perl6
