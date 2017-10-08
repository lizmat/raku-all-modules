use v6;
use Test;
plan 4;

use PDF::Content;
use PDF::Grammar::Test :is-json-equiv;
use lib '.';
use t::GfxParent;

my $parent = { :Font{ :F1{} }, } does t::GfxParent;

my $g = PDF::Content.new: :$parent;
$g.graphics: { .BeginText; .ShowText("Hi"); .EndText;};
is-json-equiv [$g.ops], [:q[], :BT[], :Tj[:literal("Hi")], "ET" => [], :Q[]];

$g = PDF::Content.new: :$parent;
$g.text: { .ShowText("Hi"); };
is-json-equiv [$g.ops], [:BT[], :Tj[:literal("Hi")], "ET" => [], ];

$g = PDF::Content.new: :$parent;
$g.marked-content( 'Foo', { .BeginText; .ShowText("Hi"); .EndText });
is-json-equiv [$g.ops], [:BMC[:name("Foo")], :BT[], :Tj[:literal("Hi")], "ET" => [], :EMC[]];

$g = PDF::Content.new: :$parent;
$g.marked-content( 'Foo', { :Bar( :Baz(42) ) }, { .BeginText; .ShowText("Hi"); .EndText; });
is-json-equiv [$g.ops], [:BDC[:name("Foo"), :dict{:Bar(:Baz(42))}], "BT" => [], :Tj[:literal("Hi")], "ET" => [], :EMC[]];

done-testing;
