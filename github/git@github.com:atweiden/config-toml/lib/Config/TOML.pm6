use v6;
use Config::TOML::Dumper;
use Config::TOML::Parser;
use X::Config::TOML;
unit module Config::TOML;

multi sub from-toml(
    Str:D $content,
    *%opts (Int :date-local-offset($))
    --> Hash:D
) is export
{
    my %toml = Config::TOML::Parser.parse($content, |%opts).made
        or die(X::Config::TOML::ParseFailed.new(:$content));
}

multi sub from-toml(
    Str:D :$file! where .so,
    *%opts (Int :date-local-offset($))
    --> Hash:D
) is export
{
    my %toml = Config::TOML::Parser.parsefile($file, |%opts).made
        or die(X::Config::TOML::ParsefileFailed.new(:$file));
}

sub to-toml(
    Associative:D $container,
    *%opts (
        # indent level of table keys relative to parent table (whitespace)
        UInt :indent-subkeys($) = 0,
        # indent level of subtables relative to parent table (whitespace)
        UInt :indent-subtables($) = 2,
        # margin between tables (newlines)
        UInt :margin-between-tables($) = 1,
        # pad inline array/hash delimiters (`[`, `]`, `{`, `}`) with whitespace
        Bool :prefer-padded-delimiters($) = True,
        # use string literals in place of basic strings whenever possible
        Bool :prefer-string-literals($) = True,
        # intersperse underlines in numbers for readability
        Bool :prefer-underlines-in-numbers($) = True,
        # the threshold # elements at which to convert array to multiline array
        UInt :threshold-multiline-array($) = 5,
        # the threshold length at which to convert string to multiline string
        UInt :threshold-multiline-string($) = 72,
        # the threshold # digits at which to intersperse underlines in numbers
        UInt :threshold-underlines-in-numbers($) = 5
    )
    --> Str:D
) is export
{
    my Str:D $toml = Config::TOML::Dumper.new.dump($container);
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
