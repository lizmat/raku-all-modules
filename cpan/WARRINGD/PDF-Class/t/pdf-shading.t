use v6;
use Test;

plan 9;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;

my PDF::Grammar::PDF::Actions $actions .= new;
my $reader = class { has $.auto-deref = False }.new;

my $input = q:to"--END-OBJ--";
5 0 obj << % Shading dictionary
  /ShadingType 3
  /ColorSpace /DeviceCMYK
  /Coords [ 0.0 0.0 0.096 0.0 0.0 1.0 00]  % Concentric circles
  /Function 10 0 R
  /Extend [ true true ]
>> endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my PDF::IO::IndObj $ind-obj .= new( |%ast, :$reader);
is $ind-obj.obj-num, 5, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $shading-obj = $ind-obj.object;
isa-ok $shading-obj, ::('PDF')::('Shading::Radial');
is $shading-obj.ShadingType, 3, '$.ShadingType accessor';
is $shading-obj.type, 'Shading', '$.type accessor';
is $shading-obj.subtype, 'Radial', '$.subtype accessor';
is $shading-obj.ColorSpace, 'DeviceCMYK', '$.ColorSpace accessor';
lives-ok {$shading-obj.check}, '$shading-obj.check lives';

is-json-equiv $ind-obj.ast, %ast, 'ast regeneration';
