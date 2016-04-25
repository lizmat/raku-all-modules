use v6;
use Config::TOML::Parser::Actions;
use Config::TOML::Parser::Grammar;
unit class Config::TOML::Parser;

method parse(Str:D $content, Int :$date-local-offset) returns Match
{
    my %opts;
    %opts<date-local-offset> = $date-local-offset if $date-local-offset;
    my Config::TOML::Parser::Actions $actions .= new(|%opts);
    Config::TOML::Parser::Grammar.parse($content, :$actions);
}

method parsefile(Str:D $file, Int :$date-local-offset) returns Match
{
    my %opts;
    %opts<date-local-offset> = $date-local-offset if $date-local-offset;
    my Config::TOML::Parser::Actions $actions .= new(|%opts);
    Config::TOML::Parser::Grammar.parsefile($file, :$actions);
}

# vim: ft=perl6
