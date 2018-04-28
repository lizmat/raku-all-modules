use v6;
use Test;
plan 3;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Content::Graphics;
use PDF::Content::Ops :OpCode;

class Graphics does PDF::Content::Graphics {
    has Str $.decoded;
    method resources($) { %() }
};

my $gfx = Graphics.new(:decoded("BT ET .5 0 0 rg"));
is-deeply $gfx.render.Str.lines, ("q", "  BT", "  ET",  "  0.5 0 0 rg", "Q"), "unsafe content has been wrapped";

$gfx = Graphics.new(:decoded("BT ET .5 0 0 rg"));
is-deeply $gfx.render(:!strict, :!tidy).Str.lines, ("BT", "ET", "0.5 0 0 rg"), ":!tidy disables wrapping";

$gfx = Graphics.new(:decoded("BT ET q .5 0 0 rg Q"));
is-deeply $gfx.render.Str.lines, ("BT", "ET", "q", "  0.5 0 0 rg", "Q"), "safe content detected";

done-testing;
