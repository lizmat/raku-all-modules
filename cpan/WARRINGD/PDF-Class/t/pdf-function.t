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
10 0 obj <<
  /FunctionType 4
  /Domain [ -1.0 1.0 -1.0 1.0 ]
  /Range [ -1.0 1.0 ]
  /Length 56
>> stream
{ 360 mul sin
  2 div
  exch 360 mul sin
  2 div
  add
}
endstream
endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my $ind-obj = PDF::IO::IndObj.new( :$input, |%ast);
is $ind-obj.obj-num, 10, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $function-obj = $ind-obj.object;
isa-ok $function-obj, ::('PDF')::('Function::PostScript');
is $function-obj.FunctionType, 4, '$.FunctionType accessor';
is $function-obj.type, 'Function', '$.type accessor';
is $function-obj.subtype, 'PostScript', '$.subtype accessor';
is-json-equiv $function-obj.Domain, [ -1.0, 1.0, -1.0, 1.0 ], '$.Domain accessor';
is-json-equiv $function-obj.Length, 56, '$.Length accessor (corrected)';
is-json-equiv $function-obj.parse, {:expr([:int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<exch>, :int(360), :op<mul>, :op<sin>, :int(2), :op<div>, :op<add>])}, '$.parse accessor';
