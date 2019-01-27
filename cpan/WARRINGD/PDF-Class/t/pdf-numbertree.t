use v6;
use Test;

plan 9;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;
use PDF::COS;
use PDF::NumberTree :NumberTree;

my PDF::Grammar::PDF::Actions $actions .= new;

my $input = q:to"--END-OBJ--";
20 0 obj <<
   /Nums [ 20  /Xxx  30  42 ]
   /Limits [20 30]
   /Kids []
>>
endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my $reader = class { has $.auto-deref = False }.new;
my PDF::IO::IndObj $ind-obj .= new( |%ast, :$reader);
is $ind-obj.obj-num, 20, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $nametree-obj = PDF::COS.coerce($ind-obj.object, PDF::NumberTree);
does-ok $nametree-obj, PDF::NumberTree;
is-json-equiv $nametree-obj.Kids, [], '$obj.First';
is-json-equiv $nametree-obj.Nums, [ 20, 'Xxx', 30, 42 ], '$obj.Nums';
my NumberTree $nums = $nametree-obj.number-tree;
is-json-equiv $nums{30}, 42, '.nums deref';
is-json-equiv $nums.Hash, { 20 => 'Xxx', 30 => 42 }, '$obj.nums';
is-json-equiv $nametree-obj.Limits, [20, 30], '$obj.Limits';
lives-ok {$nametree-obj.check}, '$nametree-obj.check lives';

