use v6;
use Config::TOML::Parser;
unit module Config::TOML;

multi sub from-toml(Str:D $content, Int :$date-local-offset) is export
{
    my %opts;
    %opts<date-local-offset> = $date-local-offset if $date-local-offset;
    Config::TOML::Parser.parse($content, |%opts).made;
}

multi sub from-toml(Str:D :$file!, Int :$date-local-offset) is export
{
    my %opts;
    %opts<date-local-offset> = $date-local-offset if $date-local-offset;
    Config::TOML::Parser.parsefile($file, |%opts).made;
}

# vim: ft=perl6
