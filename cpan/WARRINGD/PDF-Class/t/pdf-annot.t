use v6;

use Test;
use PDF;
use PDF::Class;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;
use PDF::IO::IndObj;

my $input = q:to"--END--";
22 0 obj <<
  /Type /Annot
  /Subtype /Text
  /Rect [ 100 100 300 200 ]
  /Contents (This is an open annotation. You'll need acro-reader...)
  /Open true
>> endobj
--END--

my PDF::Grammar::PDF::Actions $actions .= new;
PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed: $input";
my %ast = $/.ast;

my $reader = class { has $.auto-deref = False }.new;

my PDF::IO::IndObj $ind-obj .= new( :$input, |%ast, :$reader );
my $text-annot = $ind-obj.object;
isa-ok $text-annot, (require ::('PDF::Annot::Text'));
is-json-equiv $text-annot.Rect, [ 100, 100, 300, 200 ], '.Rect';
is $text-annot.Contents, "This is an open annotation. You'll need acro-reader...", '.Contents';

my $open-text-annot = ::('PDF::Annot::Text').new(:dict{
    :Rect[ 120, 120, 200, 200],
    :Contents("...xpdf doesn't display annotations. This annotation is closed, btw"),
    :!Open,
    :Subtype<Text>,
});

is-deeply $open-text-annot.Open, False, '.Open';
lives-ok {$open-text-annot.check}, '$open-check-annot.check lives';

my $field-annot = (require ::('PDF::Annot::Widget')).new(
    :dict{
        :Subtype<Widget>,
        :DA("/Helv 12 Tf 0 g"),
        :F(4),
        :FT<Tx>,
        :Rect[ 105, 107, 325, 130 ],
        :T<Name>,
        :V<Test>,
    }
);

isa-ok $field-annot, ::('PDF::Annot::Widget');
does-ok $field-annot, (require ::('PDF::Field::Text'));
lives-ok { $field-annot.check }, "field-annot check";

my PDF::Class $pdf .= new;
my $page = $pdf.Pages.add-page;
$page<MediaBox> = [0, 0, 350, 250];
$page<Annots> = [ $text-annot, $open-text-annot ];
$page.gfx.BeginText;
$page.gfx.TextMove(50, 50);
$page.gfx.say('Page with an open annotation');
$page.gfx.EndText;

# ensure consistant document ID generation
srand(123456);

$pdf.save-as('t/pdf-annot.pdf', :!info);

$input = q:to"--END--";
93 0 obj <<
  %%  /Type /Annot   % Type is optional
  /Subtype /Link
  /Rect [ 71 717 190 734 ]
  /Border [ 16 16 1 ]
  /Dest [ << /Type /Page >> /FitR -4 399 199 533 ]
>> endobj
--END--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed: $input";
%ast = $/.ast;

$ind-obj = PDF::IO::IndObj.new( :$input, |%ast, :$reader );
my $link-annot = $ind-obj.object;
isa-ok $link-annot, (require ::('PDF::Annot::Link'));
is-json-equiv $link-annot.Border, [ 16, 16, 1 ], '.Border';
is $link-annot.Border.vertical-radius, 16, '.Border.vertical-radius';
is-json-equiv $link-annot.Dest, [ { :Type<Page> }, 'FitR', -4, 399, 199, 533], '.Dest';
lives-ok {$link-annot.check}, '$link-annot.check lives';

$input = q:to"--END--";
7 0 obj
<</Type /Annot /Subtype /FileAttachment /Rect [240.944882 751.181339 255.118110 765.354567] /Contents (\376\377\000t\000e\000x\000t) /P 11 0 R /NM (0001-0000) /M (D:20150802122217+00'00') /F 4 /Border [0 0 0] /CreationDate (D:20150802122217+00'00') /FS (/etc/passwd) /Name /PushPin>>
endobj
--END--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed: $input";
%ast = $/.ast;

$ind-obj = PDF::IO::IndObj.new( :$input, |%ast, :$reader );
my $file-annot = $ind-obj.object;
isa-ok $file-annot, (require ::('PDF::Annot::FileAttachment'));
is $file-annot.Type, 'Annot', 'Annot with /Type defaulted';
is-json-equiv $file-annot.Border, [ 0, 0, 0 ], '.Border';
is-json-equiv $file-annot.FS, "/etc/passwd", '.FS';
is-json-equiv $file-annot.Name, 'PushPin', '.Name';
is $file-annot.Contents, "text", '.Contents';
lives-ok {$file-annot.check}, '$file-annot.check lives';

done-testing;
