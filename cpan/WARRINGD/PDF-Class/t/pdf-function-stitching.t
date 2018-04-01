use v6;
use Test;

plan 13;

use PDF::Class;
use PDF::Function::Stitching;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;

my $actions = PDF::Grammar::PDF::Actions.new;

# example taken from HTML-Canvas-To-PDF-p6/t/render-pdf-test-sheets.pdf
my $input = q:to"--END-OBJ--";
181 0 obj <<
  /Type /Pattern
  /PatternType 2
  /Matrix [ 1 0 0 1 0 592 ]
  /Shading <<
    /ShadingType 2
    /Background [ 0.78431 0.78431 1 ]
    /ColorSpace /DeviceRGB
    /Coords [ 0 200 200 0 ]
    /Domain [ 0 1 ]
    /Extend [ true true ]
    /Function <<
      /FunctionType 3
      /Bounds [ 0.5 ]
      /Domain [ 0 1 ]
      /Encode [ 0 1 0 1 ]
      /Functions [ <<
          /FunctionType 2
          /C0 [ 1 0.78431 0.78431 ]
          /C1 [ 0.78431 1 0.78431 ]
          /Domain [ 0 1 ]
          /N 1
        >> <<
          /FunctionType 2
          /C0 [ 0.78431 1 0.78431 ]
          /C1 [ 0.78431 0.78431 1 ]
          /Domain [ 0 1 ]
          /N 1
        >> ]
    >>
  >>
>>
endobj
--END-OBJ--

sub parse-ind-obj($input) {
    PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
        // die "parse failed";
    my %ast = $/.ast;
    PDF::IO::IndObj.new( :$input, |%ast);
}

sub is-result($a, $b, $test = 'calc') {
    my $ok = $a.elems == $b.elems
        && !$a.keys.first({($a[$_] - $b[$_]).abs >= 0.01 }).defined;
    ok $ok, $test;
    diag "expected {$b.perl}, got {$a.perl}"
        unless $ok;
    $ok
}

my $ind-obj = parse-ind-obj($input);
lives-ok {$ind-obj.object.check}, '$ind-obj.object.check lives';
my $sub-function-obj = $ind-obj.object<Shading><Function><Functions>[0];

given $sub-function-obj.calculator {
    is-result .calc([0.793951]), [0.828753, 0.955557, 0.784310], 'subfunction calc';
}

my $function-obj = $ind-obj.object<Shading><Function>;
isa-ok $function-obj, PDF::Function::Stitching;
is $function-obj.FunctionType, 3, '$.FunctionType accessor';
is $function-obj.type, 'Function', '$.type accessor';
is $function-obj.subtype, 'Stitching', '$.subtype accessor';
is-json-equiv $function-obj.Domain, [0, 1], '$.Domain accessor';
is-json-equiv $function-obj.Encode, [0, 1, 0, 1], '$.Encode accessor';
is-json-equiv $function-obj.Bounds, [0.5], '$.Range accessor';

given $function-obj.calculator {
    is-result .calc([0]), [1, 0.78431, 0.78431];
    is-result .calc([0.396975]), [0.828753, 0.955557, 0.784310];
    is-result .calc([0.563327]), [0.78431,  0.972682, 0.811628];
    is-result .calc([1]), [0.78431, 0.78431, 1];
}
