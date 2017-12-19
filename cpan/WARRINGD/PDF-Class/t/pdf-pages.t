use v6;
use Test;

plan 25;

use PDF::Page;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Reader;

my $actions = PDF::Grammar::PDF::Actions.new;

my $input = q:to"--END-OBJ--";
3 0 obj <<
  /Type /Pages
  /Count 2
  /Kids [4 0 R  5 0 R]
>> endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my $reader = class { has $.auto-deref = False }.new;
my $ind-obj = PDF::IO::IndObj.new( |%ast, :$reader);
is $ind-obj.obj-num, 3, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $pages-obj = $ind-obj.object;
isa-ok $pages-obj, ::('PDF')::('Pages');
is $pages-obj.Type, 'Pages', '$.Type accessor';
is $pages-obj.Count, 2, '$.Count accessor';
is-json-equiv $pages-obj.Kids, [ :ind-ref[4, 0], :ind-ref[5, 0] ], '$.Kids accessor';
is-json-equiv $pages-obj[0], (:ind-ref[4, 0]), '$pages[0] accessor';
is-json-equiv $pages-obj[1], (:ind-ref[5, 0]), '$pages[1] accessor';
is-json-equiv $ind-obj.ast, %ast, 'ast regeneration';
my $new-page = $pages-obj.add-page();
is $pages-obj.Count, 3, '$.Count accessor';
is $pages-obj.Kids[2].Type, 'Page', 'new Kid Type';

my $fdf-input = 't/pdf/fdf-PageTree.in';
$reader = PDF::Reader.new( );
$reader.open( $fdf-input );
my $pages = $reader.trailer<Root>;

is $pages.Count, 62, 'number of pages';
is $pages[0].obj-num, 3, 'first page';
is $pages[0].Rotate, 180, 'inheritance';

is $pages[1].Rotate, 90, 'inheritance';

is $pages[5].obj-num, 37, 'sixth page';

is $pages[6].obj-num, 42, 'seventh page';

is $pages[60].obj-num, 324, 'second-last page';

is $pages[61].obj-num, 330, 'last page';
is $pages[61].Rotate, 270, 'inheritance';

lives-ok {$new-page = $pages.add-page}, 'add-page - lives';
isa-ok $new-page, PDF::Page;
is $pages.Count, 63, 'number of pages';
is $pages[62].Rotate, 270, 'new page - inheritance';

$pages.core-font('Helvetica');
is-json-equiv $pages.Resources, {:Font{
    :F1{
        :Type<Font>, :Subtype<Type1>, :Encoding<WinAnsiEncoding>, :BaseFont<Helvetica>,
    }}
}, '$.Resources accessor';
