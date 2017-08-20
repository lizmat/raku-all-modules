use v6;
use Test;
plan 3;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Content::Graphics;
use PDF::Content::Ops :OpCode;

class Graphics does PDF::Content::Graphics {
    has Str $.decoded;
};

my $gfx = Graphics.new(:decoded("BT ET .5 0 0 rg"));
is-deeply $gfx.gfx.Str.lines, ("q", "  BT", "  ET",  "  0.5 0 0 rg", "Q"), "unsafe content has been wrapped";

$gfx = Graphics.new(:decoded("BT ET .5 0 0 rg"));
is-deeply $gfx.gfx(:!strict, :!encap).Str.lines, ("BT", "ET", "0.5 0 0 rg"), ":!encap disables wrapping";

$gfx = Graphics.new(:decoded("BT ET q .5 0 0 rg Q"));
is-deeply $gfx.gfx.Str.lines, ("BT", "ET", "q", "  0.5 0 0 rg", "Q"), "safe content detected";

done-testing;
