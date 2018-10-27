use v6;
use Test;
plan 14;

use PDF::Content;
use PDF::Grammar::Test :is-json-equiv;
use lib '.';
use t::GfxParent;

my $parent = { :Font{ :F1{} }, } does t::GfxParent;

my PDF::Content $g .= new: :$parent;
$g.graphics: { .BeginText; .ShowText("Hi"); .EndText;};
is-json-equiv [$g.ops], [:q[], :BT[], :Tj[:literal("Hi")], "ET" => [], :Q[]], '.graphics block';

$g .= new: :$parent;
$g.text: { .ShowText("Hi"); };
is-json-equiv [$g.ops], [:BT[], :Tj[:literal<Hi>], "ET" => [], ], '.text block';

$g .= new: :$parent;
$g.marked-content: 'Foo', {
    .BeginText;
    .ShowText("Hi");
    .EndText };
is-json-equiv [$g.ops], [:BMC[:name<Foo>], :BT[], :Tj[:literal<Hi>], "ET" => [], :EMC[]], '.marked content block';

$g .= new: :$parent;
$g.marked-content: 'Foo', :props{ :Bar{ :Baz(42) } }, {
   .BeginText;
   .ShowText("Hi");
   .EndText;
};
is-json-equiv [$g.ops], [:BDC[:name<Foo>, :dict{:Bar(:dict{:Baz(:int(42))})}], "BT" => [], :Tj[:literal<Hi>], "ET" => [], :EMC[]], '.marked content block with dict';

my $props = { :MCID(42) };

$g .= new: :$parent;
$g.marked-content: 'Foo', :$props, {
   .marked-content: 'Nested',  sub ($) { };
   $g.MarkPoint('A');
   $g.XObject('Img1');
};
$g.marked-content: 'Bar', sub ($) { };
$g.MarkPointDict('B', ${ :MCID(99) });

my PDF::Content::Tag @tags = $g.tags;
is +@tags, 3, 'top level tags';

is @tags[0].gist, '<Foo><Nested/><A/><Img1/></Foo>', '@tags[0]';
is @tags[1].gist, '<Bar/>', '@tags[1]';
is @tags[2].gist, '<B/>', '@tags[2]';

is @tags[0].mcid, 42, 'marked content id';
is @tags[0].name, 'Foo', 'marked content name';
is @tags[0].op, 'BDC', 'marked content op';

@tags[1].mcid = 99;
is @tags[1].mcid, 99, 'marked content id[1]';

my PDF::Content::Tag @tags-flat = $g.tags: :flat;
is +@tags-flat, 6, 'flat tags elems';
is [@tags-flat.map: *.name].join(','), 'Foo,Nested,A,Img1,Bar,B', 'flat tags names';

done-testing;
