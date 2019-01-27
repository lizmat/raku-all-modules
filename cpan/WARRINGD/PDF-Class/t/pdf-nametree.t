use v6;
use Test;

plan 10;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;
use PDF::COS;
use PDF::NameTree :NameTree;

my PDF::Grammar::PDF::Actions $actions .= new;

my $input = q:to"--END-OBJ--";
20 0 obj <<
   /Kids [ 10 0 R ]
   /Names [ (1.1)  /Xxx  (1.2)  42 (1.3) 3.14 ]
   /Limits [(1.1) (1.3)]
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
my $nametree-obj = PDF::COS.coerce($ind-obj.object, PDF::NameTree);
does-ok $nametree-obj, PDF::NameTree;
is-json-equiv $nametree-obj.Names, [ '1.1', 'Xxx', '1.2', 42, '1.3', 3.14 ], '$obj.Names';
is-json-equiv $nametree-obj.Kids, [:ind-ref[10, 0]], '$obj.First';
$nametree-obj.Kids = [];
my NameTree $names = $nametree-obj.name-tree;
for '1.1' => 'Xxx', '1.2' => 42, '1.3' => 3.14 {
   is $names{.key}, .value, "names\{{.key}\}";
}
is-deeply $names.keys.sort, ('1.1', '1.2', '1.3'), '$.keys';
lives-ok {$nametree-obj.check}, '$nametree-obj.check lives';

