use v6;
use Test;

plan 14;

use PDF::Class;
use PDF::Function::Exponential;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;

my PDF::Grammar::PDF::Actions $actions .= new;

my $input = q:to"--END-OBJ--";
5 0 obj [ /Separation /BarTone 1 0 R <<
    /FunctionType 2
    /C0 [ 100 0 0 ]
    /C1 [ 50 -30 -40 ]
    /Domain [ 0 1 ]
    /N 1
    /Range [ 0 100 -128 127 -128 127 ]
  >> ]
endobj
--END-OBJ--

sub parse-ind-obj($input) {
    PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
        // die "parse failed";
    my %ast = $/.ast;
    PDF::IO::IndObj.new( :$input, |%ast);
}

my $ind-obj = parse-ind-obj($input);
my $function-obj = $ind-obj.object[3];
isa-ok $function-obj, PDF::Function::Exponential;
is $function-obj.FunctionType, 2, '$.FunctionType accessor';
is $function-obj.type, 'Function', '$.type accessor';
is $function-obj.subtype, 'Exponential', '$.subtype accessor';
is $function-obj.N, 1, '$.N accessor';
is-json-equiv $function-obj.Domain, [0, 1], '$.Domain accessor';
is-json-equiv $function-obj.Range, [0, 100, -128, 127, -128, 127], '$.Range accessor';
lives-ok {$function-obj.check}, '$function-obj.check lives';

sub is-result($a, $b, $test = 'calc') {
    my $ok = $a.elems == $b.elems
        && !$a.keys.first({($a[$_] - $b[$_]).abs >= 0.01 }).defined;
    ok $ok, $test;
    diag "expected {$b.perl}, got {$a.perl}"
        unless $ok;
    $ok
}

given $function-obj.calculator {
    is-result .calc([0]), [100, 0, 0];
    is-result .calc([1]), [50, -30, -40];
    is-result .calc([.5]), [75, -15, -20];
}

$function-obj.N = 1.1;
given $function-obj.calculator {
    is-result .calc([0]), [100, 0, 0];
    is-result .calc([1]), [50, -30, -40];
    is-result .calc([.5]), [76.674, -13.995, -18.661];
}

