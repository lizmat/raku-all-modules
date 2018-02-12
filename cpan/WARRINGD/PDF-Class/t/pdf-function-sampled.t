use v6;
use Test;

plan 35;

use PDF::Class;
use PDF::Function::Sampled;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;

my $actions = PDF::Grammar::PDF::Actions.new;

my $input = q:to"--END-OBJ--";
6 0 obj <<
  /FunctionType 0
  /BitsPerSample 8
  /Domain [ 0 1 ]
  /Filter /ASCIIHexDecode
  /Range [ 0 1 0 1 0 1 0 1 ]
  /Size [ 2 ]
  /Length 17
>> stream
00112130FFFFFFA0>
endstream
endobj
--END-OBJ--

sub parse-ind-obj($input) {
    PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
        // die "parse failed";
    my %ast = $/.ast;
    PDF::IO::IndObj.new( :$input, |%ast);
}

my $ind-obj = parse-ind-obj($input);
my $function-obj = $ind-obj.object;
isa-ok $function-obj, PDF::Function::Sampled;
is $function-obj.FunctionType, 0, '$.FunctionType accessor';
is $function-obj.type, 'Function', '$.type accessor';
is $function-obj.subtype, 'Sampled', '$.subtype accessor';
is-json-equiv $function-obj.Domain, [0, 1], '$.Domain accessor';
is-json-equiv $function-obj.Length, 17, '$.Length accessor';

sub is-result($a, $b, $test = 'calc') {
    my $ok = $a.elems == $b.elems
        && !$a.keys.first({($a[$_] - $b[$_]).abs >= 0.01 }).defined;
    ok $ok, $test;
    diag "expected {$b.perl}, got {$a.perl}"
        unless $ok;
    $ok
}

given  $function-obj.calculator {
    is-result .calc([0]), [0, 17/255, 33/255, 48/255];
    is-result .calc([1]), [1, 1, 1, 160/255];
    is-result .calc([.5]), [1/2, 136/255, 144/255, 104/255];
    is-result .calc([.25]), [1/4, 3/10, 88.5/255, 76/255];
}

$function-obj.Encode = [0, 2];

given  $function-obj.calculator {
    is-result .calc([0]), [0, 17/255, 33/255, 48/255];
    is-result .calc([1]), [1, 1, 1, 160/255];
    is-result .calc([.5]), [1, 1, 1, 160/255];
    is-result .calc([.25]), [1/2, 136/255, 144/255, 104/255];
}

$function-obj.Encode = [0, .8];

is-result $function-obj.calc([.5]), [0.400000, 0.440000, 0.477647, 0.363922];
is-result $function-obj.calc([1]), [0.800000, 0.813333, 0.825882, 0.539608];

$function-obj.Encode = [0, 1];
$function-obj.Range = [0, 1, -1, 1, 0, 2, 1, 2];

given  $function-obj.calculator {
    is-result .calc([0]), [0, -221/255, 66/255, 303/255];
    is-result .calc([.5]), [1/2, 17/255, 288/255, 359/255];
    is-result .calc([1]), [1, 1, 2, 415/255];
    is-result .calc([.25]), [1/4, -102/255, 177/255, 331/255];
}

$function-obj.Range  = [0, 1, 0, 1, 0, 1, 0, 2];
$function-obj.Decode = [0, 1, -1, 1, 0, 2, 1, 2];

given  $function-obj.calculator {
    is-result .calc([0]), [0, 0, 66/255, 303/255];
    is-result .calc([.5]), [1/2, 17/255, 1, 359/255];
    is-result .calc([1]), [1, 1, 1, 415/255];
    is-result .calc([.25]), [1/4, 0, 177/255, 331/255];
}

$function-obj.Range  = [0, 1, 0, 1, 0, 1, 0, 1];
$function-obj.Decode = [0, 1, 0, 1, 0, 1, 0, 1];
$function-obj.encoded = q:to<END-SAMPLE>;
00 11 21 30
A1 A2 A3 A4
FF FF FF A0>
END-SAMPLE

$function-obj.Size = 3;

given  $function-obj.calculator {
    is-result .calc([0]), [0, 17/255, 33/255, 48/255];
    is-result .calc([1]), [161/255, 162/255, 163/255, 164/255];
    is-result .calc([.5]), [80.5/255, 89.5/255, 98/255, 106/255];
    is-result .calc([.25]), [.157843, 0.208824, 0.256863, 0.301961,];

}

# mag-yel(c1,c2): simple function to map [M, Y] => [C, M, 2/3.Y, K]
# samples:
# f(0, 0) = 00 00 00 00
# f(1, 0) = 00 ff 00 00
# f(0, 1) = 00 00 aa 00
# f(1, 1) = 00 ff aa 00
$input = q:to"--END-OBJ--";
22 0 obj << /BitsPerSample 8 /Domain [ 0 1 0 1 ] /Filter [ /ASCIIHexDecode ] /FunctionType 0 /Length 25 0 R /Range [ 0 1 0 1 0 1 0 1 ] /Size [ 2 2 ] >> stream
00 00 00 00
00 ff 00 00
00 00 aa 00
00 ff aa 00>
endstream endobj
--END-OBJ--

$ind-obj = parse-ind-obj($input);
$function-obj = $ind-obj.object;

given $function-obj.calculator {
    is-result .calc([0, 0]), [0, 0, 0, 0], 'mag-yel(0,0)';
    is-result .calc([1, 1]), [0, 1, 2/3, 0], 'mag-yel(1,1)';
    is-result .calc([1, .5]), [0, 1, 1/3, 0], 'mag-yel(1,.5)';
    is-result .calc([.5, .25]), [0, 1/2, 1/6, 0], 'mag-yel(.5,.25)';
}

# cyan-mag-yel(c1,c2,c3): simple function to map [C, M, Y] => [1/3.C, M, 2/3.Y, K]
# samples:
# f(0,0,0) = 00 00 00 00
# f(1,0,0) = 55 00 00 00
# f(0,1,0) = 00 ff 00 00
# f(1,1,0) = 55 ff 00 00
# f(0,0,1) = 00 00 aa 00
# f(1,0,1) = 55 00 aa 00
# f(0,1,1) = 00 ff aa 00
# f(1,1,1) = 55 ff aa 00

$input = q:to"--END-OBJ--";
26 0 obj << /BitsPerSample 8 /Domain [ 0 1 0 1 0 1 ] /Filter [ /ASCIIHexDecode ] /FunctionType 0 /Length 28 0 R /Order 3 /Range [ 0 1 0 1 0 1 0 1 ] /Size [ 2 2 2 ] >>
stream
00 00 00 00
55 00 00 00
00 ff 00 00
55 ff 00 00
00 00 aa 00
55 00 aa 00
00 ff aa 00
55 ff aa 00>
endstream endobj
--END-OBJ--

    $ind-obj = parse-ind-obj($input);
$function-obj = $ind-obj.object;

given $function-obj.calculator {
    is-result .calc([0, 0, 0]), [0, 0, 0, 0], 'cyan-mag-yel(0,0,0)';
    is-result .calc([1, 1, 1]), [1/3, 1, 2/3, 0], 'cyan, mag-yel(1,1,1)';
    is-result .calc([1, 1/3, .5]), [1/3, 1/3, 1/3, 0], 'cyan, mag-yel(1,1/3,.5)';

}
