use v6;
use Config::TOML;
use Sustenance::Parser::ParseTree;
use Sustenance::Types;
unit class Sustenance::Parser;

multi sub from-sustenance(Str:D :$file! where .so --> Hash:D) is export
{
    my %toml = from-toml(:$file);
    my %sustenance = from-sustenance(:%toml);
}

multi sub from-sustenance(Str:D $content --> Hash:D) is export
{
    my %toml = from-toml($content);
    my %sustenance = from-sustenance(:%toml);
}

multi sub from-sustenance(:%toml! --> Hash:D)
{
    my Food:D @food = %toml<food>.map(-> %food { Food.new(|%food) });
    my Pantry $pantry .= new(:@food);
    my Meal:D @meal = %toml<meal>.map(-> %meal { Meal.new(|%meal) });
    my %sustenance = :$pantry, :@meal;
}

# vim: set filetype=perl6 foldmethod=marker foldlevel=0:
