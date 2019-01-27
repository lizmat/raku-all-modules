use v6;
use Test;

plan 17;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;
use PDF::COS;
my PDF::Grammar::PDF::Actions $actions .= new;

my $input = q:to"--END-OBJ--";
18 0 obj <<
  /Type /Outlines
  /Count 3
  /First 19 0 R
  /Last 20 0 R >> endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my $reader = class { has $.auto-deref = False }.new;
my PDF::IO::IndObj $ind-obj .= new( |%ast, :$reader);
is $ind-obj.obj-num, 18, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $outlines-obj = $ind-obj.object;
does-ok $outlines-obj, (require ::('PDF')::('Outlines'));
is $outlines-obj.Type, 'Outlines', '$.Type accessor';
is $outlines-obj.Count, 3, '$.Count accessor';
is-deeply $outlines-obj.First, (:ind-ref[19, 0]), '$obj.First';
is-deeply $outlines-obj.Last, (:ind-ref[20, 0]), '$obj.Last';
lives-ok {$outlines-obj.check}, '$outlines-obj.check lives';
is-json-equiv $ind-obj.ast, %ast, 'ast regeneration';

$outlines-obj = PDF::COS.coerce({}, (require ::('PDF')::('Outlines')));
$outlines-obj.add-kid({:Title<k1>});
$outlines-obj.add-kid({:Title<k2>});
$outlines-obj.First.add-kid({:Title<k3>});
my @titles = $outlines-obj.kids.map: *.Title;
is-deeply @titles.join(','), 'k1,k2', 'titles';
is $outlines-obj.First.Title, 'k1', '.First';
is $outlines-obj.Last.Title, 'k2', '.Last';
is $outlines-obj.First.First.Title, 'k3', '.First.First';

$outlines-obj = PDF::COS.coerce({}, (require ::('PDF')::('Outlines')));

$outlines-obj.kids = ({:Title<k1>, :kids[ {:Title<k3>}, ] }, {:Title<k2>});

@titles = $outlines-obj.kids.map: *.Title;
is-deeply @titles.join(','), 'k1,k2', 'titles';
is $outlines-obj.First.Title, 'k1', 'kids-accessor: .First';
is $outlines-obj.Last.Title, 'k2', 'kids-accessor: .Last';
is $outlines-obj.First.First.Title, 'k3', 'kids-accessor: .First.First';


