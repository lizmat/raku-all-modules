use v6;
use Test;

plan 9;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;

my $actions = PDF::Grammar::PDF::Actions.new;

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
my $ind-obj = PDF::IO::IndObj.new( |%ast, :$reader);
is $ind-obj.obj-num, 18, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $outlines-obj = $ind-obj.object;
isa-ok $outlines-obj, (require ::('PDF')::('Outlines'));
is $outlines-obj.Type, 'Outlines', '$.Type accessor';
is $outlines-obj.Count, 3, '$.Count accessor';
is-deeply $outlines-obj.First, (:ind-ref[19, 0]), '$obj.First';
is-deeply $outlines-obj.Last, (:ind-ref[20, 0]), '$obj.Last';
lives-ok {$outlines-obj.check}, '$outlines-obj.check lives';
is-json-equiv $ind-obj.ast, %ast, 'ast regeneration';
