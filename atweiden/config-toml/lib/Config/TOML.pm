use v6;
use Config::TOML::Parser;
unit module Config::TOML;

sub from-toml($text, Int :$date-local-offset) is export
{
    Config::TOML::Parser.parse(
        $text,
        :date_local_offset($date-local-offset)
    ).made;
}

# vim: ft=perl6
