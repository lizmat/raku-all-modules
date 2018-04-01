use v6;
use Test;

plan 43;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Page;

my $actions = PDF::Grammar::PDF::Actions.new;

my $input = q:to"--END-OBJ--";
215 0 obj <<
  /Type /Catalog
  /Lang (EN-US)
  /LastModified (D:20081012130709)
  /MarkInfo << /LetterspaceFlags 0 /Marked true >>
  /Metadata 10 0 R
  /Outlines 18 0 R
  /PageLayout /OneColumn
  /Pages 212 0 R
  /PieceInfo << /MarkedPDF << /LastModified (D:20081012130709) >> >>
  /StructTreeRoot 25 0 R
  /AcroForm << /Fields [] >>
  /ViewerPreferences << /HideToolbar true /Direction /R2L >>
  /PageLabels << /Nums [
    0 << /S /r >>
    4 << /S /D >>
    7 << /S /D /P (A-) /St 8 >>
    ]
  >>
>> endobj
--END-OBJ--

my $reader = class { has $.auto-deref = False }.new;

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my $ind-obj = PDF::IO::IndObj.new( |%ast, :$reader);
is $ind-obj.obj-num, 215, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $catalog = $ind-obj.object;
isa-ok $catalog, ::('PDF')::('Catalog');
is $catalog<PageLayout>, 'OneColumn', 'dict lookup';
is-json-equiv $catalog.Lang, 'EN-US', '$catalog.Lang';
# last modified is not listed as a property in [ PDF 1.7 TABLE 3.25 Entries in the catalog dictionary]
is-json-equiv $catalog.Type, 'Catalog', '$catalog.Type';
isa-ok $catalog.Type, Str, 'catalog $.Type';
ok ! $catalog.subtype.defined, 'catalog $.subtype';
is-json-equiv $catalog<LastModified>, 'D:20081012130709', '$catalog<LastModified>';
is-json-equiv $catalog.MarkInfo, { :LetterspaceFlags(0), :Marked }, '$object.MarkInfo'; 
is-json-equiv $catalog.Metadata, (:ind-ref[10, 0]), '$catalog.Metadata';
is-json-equiv $catalog.Outlines, (:ind-ref[18, 0]), '$catalog.Outlines';
is-json-equiv $catalog.PageLabels.Nums, [0, { :S<r> }, 4, { :S<D> }, 7, { :S<D>, :P<A->, :St(8), }, ], '$catalog.PageLabels';
is-json-equiv $catalog.PageLayout, 'OneColumn', '$catalog.PageLayout';
is-json-equiv $catalog.Pages, (:ind-ref[212, 0]), '$catalog.Pages';
is-json-equiv $catalog.PieceInfo, { :MarkedPDF{ :LastModified<D:20081012130709> } }, '$catalog.PieceInfo';
is-json-equiv $catalog.StructTreeRoot, (:ind-ref[25, 0]), '$catalog.StructTreeRoot';
is-json-equiv $ind-obj.ast, %ast, 'ast regeneration';

my $acroform = $catalog.AcroForm;
does-ok $acroform, ::('PDF::AcroForm'), '$.AcroForm role';
is-json-equiv $acroform.Fields, [], '$.AcroForm.Fields';

my $viewer-preferences = $catalog.ViewerPreferences;
does-ok $viewer-preferences, ::('PDF::ViewerPreferences'), '$.ViewerPreferences role';
is-json-equiv $viewer-preferences.HideToolbar, True, '$.ViewerPreferences.HideToolbar';
is-json-equiv $viewer-preferences.Direction, 'R2L', '$.ViewerPreferences.Direction';

my $page = PDF::Page.new;
dies-ok { $catalog.OpenAction = [$page, 'FitH', 'blah' ] }, '$catalog.OpenAction assignment - invalid';
lives-ok { $catalog.OpenAction = [$page, 'FitH', 42 ] }, '$catalog.OpenAction assignment - numeric';
is-json-equiv $catalog.OpenAction, [$page, 'FitH', 42 ], '$catalog.OpenAction assignment - numeric';

my $null = PDF::COS.coerce( :null(Any) );
lives-ok { $catalog.OpenAction = [$page, 'FitH', $null ] }, '$catalog.OpenAction assignment - null';
is-json-equiv $catalog.OpenAction, [$page, 'FitH', Mu ], '$catalog.OpenAction assignment - null';

lives-ok { $catalog.OpenAction = { :S( :name<GoTo> ), :D[$page, :name<Fit>] } }, '$catalog.OpenAction assignment - destination dict';
is-json-equiv $catalog.OpenAction, { :S<GoTo>, :D[$page, 'Fit'] }, '$catalog.OpenAction - destination dict';
does-ok $catalog.OpenAction, ::('PDF')::('Action::GoTo');

lives-ok { $catalog.URI = { :S( :name<URI> ), :URI("http://example.com") } }, '$catalog.URI assignment - destination dict';
is-json-equiv $catalog.URI, { :S<URI>, :URI("http://example.com") }, '$catalog.URI - destination dict';
does-ok $catalog.URI, ::('PDF')::('Action::URI');

lives-ok {$catalog.core-font('Helvetica')}, 'can add resource (core-font) to catalog';
is-json-equiv $catalog.Resources, {:Font{
    :F1{
        :Type<Font>, :Subtype<Type1>, :Encoding<WinAnsiEncoding>, :BaseFont<Helvetica>,
    }}
}, '$.Resources accessor';
lives-ok {$catalog.check}, '$catalog.check lives';

$catalog<Dests> = { :Foo(:name<Bar>) };
ok $catalog.Dests.obj-num, 'entry(:indirect)';

# crosschecks on /Type
my $dict = { :Type( :name<Catalog> ) };
lives-ok {$catalog = ::('PDF::Catalog').new( :$dict )}, 'catalog .new with valid /Type - lives';
$dict<Type>:delete;

lives-ok {$catalog = ::('PDF::Catalog').new( :$dict )}, 'catalog .new default /Type - lives';
isa-ok $catalog.Type, Str, 'catalog $.Type';
is $catalog.Type, 'Catalog', 'catalog $.Type';

$dict<Type> = :name<Wtf>;
todo "type-check on new";
dies-ok {::('PDF::Catalog').new( :$dict )}, 'catalog .new with invalid /Type - dies';
