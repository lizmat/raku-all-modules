use v6;
use Test;

plan 10;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

my PDF::Grammar::PDF::Actions $actions .= new;

my $input = q:to"--END-OBJ--";
6 0 obj% Form XObject
<<
  /Type /XObject
  /Subtype /Form
  /FormType 1
  /BBox [ 0 0 200 200 ]
  /Matrix [ 1 0 0 1 0 0 ]
  /Resources << /ProcSet [ /PDF ] >>
  /Length 58
>> stream
0 0 m
0 200 l
200 200 l
200 0 l
f
endstream endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my PDF::IO::IndObj $ind-obj .= new( |%ast, :$input);
is $ind-obj.obj-num, 6, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $xform = $ind-obj.object;
isa-ok $xform, (require ::('PDF')::('XObject::Form'));
is $xform.Type, 'XObject', '$.Type accessor';
is $xform.Subtype, 'Form', '$.Subtype accessor';
is-json-equiv $xform.Resources, { :ProcSet( [ <PDF> ] ) }, '$.Resources accessor';
is-json-equiv $xform.BBox, [ 0, 0, 200, 200 ], '$.BBox accessor';
is $xform.encoded, "0 0 m\n0 200 l\n200 200 l\n200 0 l\nf", '$.encoded accessor';
$xform.gfx.Save;
$xform.gfx.BeginText;
$xform.gfx.TextMove(50, 50);
$xform.gfx.op('rg', .5, .95, .5);
my $font = $xform.core-font( :family<Helvetica>, :weight<bold> );
$xform.gfx.set-font($font);
$xform.gfx.say('Hello, again!');
$xform.gfx.EndText;
$xform.gfx.Restore;
$xform.cb-finish;
lives-ok {$xform.check}, '$xform.check lives';

my $contents = $xform.decoded;
is-deeply [$contents.lines], [
    'q',
    '0 0 m', '0 200 l', '200 200 l', '200 0 l', 'f',
    'Q',
    'q',
    '  BT',
    '    50 50 Td',
    '    0.5 0.95 0.5 rg',
    '    /F1 16 Tf',
    '    (Hello, again!) Tj',
    '    17.6 TL', 
    '    T*',
    '  ET',
    'Q',
    ], 'finished contents';

my PDF::Class $pdf .= new;
$pdf.Pages.media-box = [0, 0, 220, 220];
my $page = $pdf.add-page;
$page.graphics: {
    $page.gfx.do($xform, 10, 15, :width(100), :height(190));
    $page.gfx.do($xform, 120, 15, :width(90));
    $page.gfx.do($xform, 120, 115, :width(90));

    $page = $pdf.add-page;

    my $x = 50;

    for <top center bottom> -> $valign {

	my $y = 170;

	for <left center right> -> $align {
	    $page.gfx.do($xform, $x, $y, :width(40), :$align, :$valign);
	    $y -= 60;
	}
	$x += 60;
    }
}

# ensure consistant document ID generation
srand(123456);
$pdf.save-as('t/pdf-xobject-form.pdf', :!info);
