use v6;
use Config::TOML::Parser;
unit module Config::TOML;

multi sub from-toml(Str:D $content, Int :$date-local-offset) is export
{
    Config::TOML::Parser.parse($content, :$date-local-offset).made;
}

multi sub from-toml(Str:D :$file!, Int :$date-local-offset) is export
{
    Config::TOML::Parser.parsefile($file, :$date-local-offset).made;
}

# vim: ft=perl6
