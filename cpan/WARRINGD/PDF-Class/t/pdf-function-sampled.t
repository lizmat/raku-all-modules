use v6;
use Test;

plan 41;

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
00 11 21 30
FF FF FF A0>
endstream
endobj
--END-OBJ--

sub parse-ind-obj($input) {
    PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
        // die "parse failed";
    my %ast = $/.ast;
    PDF::IO::IndObj.new( :$input, |%ast);
}

sub is-result($a, $b, $test = 'calc', :$rel-tol = 0.002) {
    my $ok = $a.elems == $b.elems
        && !$a.keys.first({($a[$_] - $b[$_]).abs >= $rel-tol }).defined;
    ok $ok, $test;
    diag "result {$a.perl}"
        unless $ok;
    $ok
}

sub is-result-calc($fun, $a, $b, $test = "calc", |c) {
    is-result($fun.calc($a), $b, $test ~ ": [$a] --> [$b]", |c);
}

my $ind-obj = parse-ind-obj($input);
my $function-obj = $ind-obj.object;
isa-ok $function-obj, PDF::Function::Sampled;
is $function-obj.FunctionType, 0, '$.FunctionType accessor';
is $function-obj.type, 'Function', '$.type accessor';
is $function-obj.subtype, 'Sampled', '$.subtype accessor';
is-json-equiv $function-obj.Domain, [0, 1], '$.Domain accessor';
is-json-equiv $function-obj.Length, 17, '$.Length accessor';

given  $function-obj.calculator {
    is-result-calc $_, [0], [0, 17/255, 33/255, 48/255], 'basic';
    is-result-calc $_, [1], [1, 1, 1, 160/255], 'basic';
    is-result-calc $_, [.5], [1/2, 136/255, 144/255, 104/255], 'basic';
    is-result-calc $_, [.25], [1/4, 3/10, 88.5/255, 76/255], 'basic';
}

$function-obj.Encode = [0, 2];

given  $function-obj.calculator {
    is-result-calc $_, [0], [0, 17/255, 33/255, 48/255], '/Encode [0 2]';
    is-result-calc $_, [1], [1, 1, 1, 160/255], '/Encode [0 2]';
    is-result-calc $_, [.5], [1, 1, 1, 160/255], '/Encode [0 2]';
    is-result-calc $_, [.25], [1/2, 136/255, 144/255, 104/255], '/Encode [0 2]';
}

$function-obj.Encode = [0, .8];

is-result-calc $function-obj, [.5], [0.400000, 0.440000, 0.477647, 0.363922], '/Encode [0 /8]';
is-result-calc $function-obj, [1], [0.800000, 0.813333, 0.825882, 0.539608], '/Encode [0 /8]';

$function-obj.Encode = [0, 1];
$function-obj.Range = [0, 1, -1, 1, 0, 2, 1, 2];

given  $function-obj.calculator {
    is-result-calc $_, [0], [0, -221/255, 66/255, 303/255], 'ranges';
    is-result-calc $_, [.5], [1/2, 17/255, 288/255, 359/255], 'ranges';
    is-result-calc $_, [1], [1, 1, 2, 415/255], 'ranges';
    is-result-calc $_, [.25], [1/4, -102/255, 177/255, 331/255], 'ranges';
}

$function-obj.Range  = [0, 1, 0, 1, 0, 1, 0, 2];
$function-obj.Decode = [0, 1, -1, 1, 0, 2, 1, 2];

given  $function-obj.calculator {
    is-result-calc $_, [0], [0, 0, 66/255, 303/255], 'decodings';
    is-result-calc $_, [.5], [1/2, 17/255, 1, 359/255], 'decodings';
    is-result-calc $_, [1], [1, 1, 1, 415/255], 'decodings';
    is-result-calc $_, [.25], [1/4, 0, 177/255, 331/255], 'decodings';
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
    is-result-calc $_, [0], [0, 17/255, 33/255, 48/255], 'Size 3';
    is-result-calc $_, [1], [161/255, 162/255, 163/255, 164/255], 'Size 3';
    is-result-calc $_, [.5], [80.5/255, 89.5/255, 98/255, 106/255], 'Size 3';
    is-result-calc $_, [.25], [.157843, 0.208824, 0.256863, 0.301961,], 'Size 3';

}

# mag-yel(c1,c2): simple function to map [M, Y] => [C, M, 2/3.Y, K]
# samples:
# f(0, 0) = 00 00 00 00 #offset:0
# f(1, 0) = 00 ff 00 00 #offset:4
# f(0, 1) = 00 00 aa 00 #offset:8
# f(1, 1) = 00 ff aa 00 #offset:12
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
    is-result-calc $_, [0, 0], [0, 0, 0, 0], 'mag-yel';
    is-result-calc $_, [1, 1], [0, 1, 2/3, 0], 'mag-yel';
    is-result-calc $_, [1, .5], [0, 1, 1/3, 0], 'mag-yel';
    is-result-calc $_, [.5, .25], [0, 1/2, 1/6, 0], 'mag-yel';
}

# cyan-mag-yel(c1,c2,c3): simple function to map [C, M, Y] => [1/3.C, M, 2/3.Y, K]
# samples:
# f(0,0,0) = 00 00 00 00 / ff
# f(1,0,0) = 55 00 00 00 "
# f(0,1,0) = 00 ff 00 00 "
# f(1,1,0) = 55 ff 00 00 "
# f(0,0,1) = 00 00 aa 00 "
# f(1,0,1) = 55 00 aa 00 "
# f(0,1,1) = 00 ff aa 00 "
# f(1,1,1) = 55 ff aa 00 "

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
    is-result-calc $_, [0, 0, 0], [0, 0, 0, 0], 'cyan-mag-yel';
    is-result-calc $_, [1, 1, 1], [1/3, 1, 2/3, 0], 'cyan-mag-yel';
    is-result-calc $_, [1/2, 1/2, 1/2], [1/6, 1/2, 1/3, 0], 'cyan-mag-yel';
    is-result-calc $_, [1, 1/3, 1/2], [1/3, 1/3, 1/3, 0], 'cyan-mag-yel';
}

$input = q:to"--END-OBJ--";
24 0 obj
<<
/FunctionType 0
/BitsPerSample 8
/Range [-1 1]
/Filter /ASCIIHexDecode
/Domain [-1 1 -1 1]
/Size [33 33]
>>
% -15      |     -10      |      -5      |      0       |      5       |      10      |      15 16/16
stream
7F 7F 71 1C 1C 05 0C 61 61 7E 6F 1A 1A 06 0E 63 63 7F 71 1C 1C 05 0C 0C 61 7D 6F 6F 1A 07 0E 0E 63
7F 7F 71 1C 1C 05 0C 61 61 7E 6F 1A 1A 06 0E 63 63 7F 71 1C 1C 05 0C 0C 61 7D 6F 6F 1A 07 0E 0E 63
6A 6A 4E 3A 3A 1E 30 45 45 68 4C 3B 3B 1E 31 46 46 6A 4D 3A 3A 1D 2F 2F 44 68 4B 4B 3B 1F 31 31 47
15 15 25 57 57 73 4F 37 37 13 25 57 57 73 50 38 38 15 25 56 56 72 4F 4F 36 13 26 26 57 74 50 50 38
15 15 25 57 57 73 4F 37 37 13 25 57 57 73 50 38 38 15 25 56 56 72 4F 4F 36 13 26 26 57 74 50 50 38
02 02 09 5E 5E 7A 6C 17 17 02 09 5E 5E 7A 6C 17 17 01 08 5D 5D 7A 6B 6B 16 02 0A 0A 5F 7B 6D 6D 18
21 21 2C 41 41 65 48 3E 3E 22 2C 42 42 65 49 3C 3C 20 2C 41 41 64 48 48 3F 22 2D 2D 42 66 49 49 3D
76 76 52 33 33 10 29 5B 5B 77 53 34 34 10 27 59 59 75 52 33 33 0F 29 29 5B 77 54 54 34 11 28 28 59
76 76 52 33 33 10 29 5B 5B 77 53 34 34 10 27 59 59 75 52 33 33 0F 29 29 5B 77 54 54 34 11 28 28 59
7D 7D 6E 19 19 06 0D 62 62 7E 70 1B 1B 04 0B 60 60 7C 6E 19 19 06 0D 0D 62 7E 70 70 1B 04 0B 0B 60
67 67 4B 3C 3C 1F 30 45 45 69 4C 39 39 1D 2E 44 44 67 4B 3C 3C 20 30 30 46 69 4D 4D 39 1D 2F 2F 44
12 12 26 58 58 74 51 37 37 14 24 55 55 72 4E 35 35 12 27 58 58 75 51 51 38 14 24 24 56 72 4F 4F 36
12 12 26 58 58 74 51 37 37 14 24 55 55 72 4E 35 35 12 27 58 58 75 51 51 38 14 24 24 56 72 4F 4F 36
03 03 0A 5F 5F 7B 6D 18 18 00 07 5C 5C 79 6A 15 15 03 0A 5F 5F 7C 6E 6E 19 01 08 08 5D 79 6B 6B 16
23 23 2D 43 43 66 4A 3D 3D 21 2B 40 40 63 47 40 40 23 2E 43 43 66 4A 4A 3E 21 2B 2B 40 64 47 47 3F
78 78 54 34 34 11 28 5A 5A 76 53 32 32 0E 2A 5C 5C 78 55 35 35 11 29 29 5A 76 53 53 32 0F 2A 2A 5B
78 78 54 34 34 11 28 5A 5A 76 53 32 32 0E 2A 5C 5C 78 55 35 35 11 29 29 5A 76 53 53 32 0F 2A 2A 5B
7F 7F 71 1C 1C 05 0C 61 61 7D 6F 1A 1A 07 0E 63 63 7F 71 1C 1C 05 0C 0C 61 7E 6F 6F 1A 06 0E 0E 63
6A 6A 4D 3A 3A 1D 2F 44 44 68 4B 3B 3B 1F 31 47 47 6A 4E 3A 3A 1E 30 30 45 68 4C 4C 3B 1E 31 31 46
15 15 25 56 56 72 4F 36 36 13 26 57 57 74 50 38 38 15 25 57 57 73 4F 4F 37 13 25 25 57 73 50 50 38
15 15 25 56 56 72 4F 36 36 13 26 57 57 74 50 38 38 15 25 57 57 73 4F 4F 37 13 25 25 57 73 50 50 38
01 01 08 5D 5D 7A 6B 16 16 02 0A 5F 5F 7B 6D 18 18 02 09 5E 5E 7A 6C 6C 17 02 09 09 5E 7A 6C 6C 17
20 20 2C 41 41 64 48 3F 3F 22 2D 42 42 66 49 3D 3D 21 2C 41 41 65 48 48 3E 22 2C 2C 42 65 49 49 3C
20 20 2C 41 41 64 48 3F 3F 22 2D 42 42 66 49 3D 3D 21 2C 41 41 65 48 48 3E 22 2C 2C 42 65 49 49 3C
75 75 52 33 33 0F 29 5B 5B 77 54 34 34 11 28 59 59 76 52 33 33 10 29 29 5B 77 53 53 34 10 27 27 59
7C 7C 6E 19 19 06 0D 62 62 7E 70 1B 1B 04 0B 60 60 7D 6E 19 19 06 0D 0D 62 7E 70 70 1B 04 0B 0B 60
67 67 4B 3C 3C 20 30 46 46 69 4D 39 39 1D 2F 44 44 67 4B 3C 3C 1F 30 30 45 69 4C 4C 39 1D 2E 2E 44
67 67 4B 3C 3C 20 30 46 46 69 4D 39 39 1D 2F 44 44 67 4B 3C 3C 1F 30 30 45 69 4C 4C 39 1D 2E 2E 44
12 12 27 58 58 75 51 38 38 14 24 56 56 72 4F 36 36 12 26 58 58 74 51 51 37 14 24 24 55 72 4E 4E 35
03 03 0A 5F 5F 7C 6E 19 19 01 08 5D 5D 79 6B 16 16 03 0A 5F 5F 7B 6D 6D 18 00 07 07 5C 79 6A 6A 15
23 23 2E 43 43 66 4A 3E 3E 21 2B 40 40 64 47 3F 3F 23 2D 43 43 66 4A 4A 3D 21 2B 2B 40 63 47 47 40
23 23 2E 43 43 66 4A 3E 3E 21 2B 40 40 64 47 3F 3F 23 2D 43 43 66 4A 4A 3D 21 2B 2B 40 63 47 47 40
78 78 55 35 35 11 29 5A 5A 76 53 32 32 0F 2A 5B 5B 78 54 34 34 11 28 28 5A 76 53 53 32 0E 2A 2A 5C>
endstream 
% -15      |     -10      |      -5      |      0       |      5       |      10      |      15 16/16
endobj 
--END-OBJ--

$ind-obj = parse-ind-obj($input);
$function-obj = $ind-obj.object;

given $function-obj.calculator {
    # exact points
    is-result-calc $_, [-15/16, -1], [-1/255], 'Size 33x33';
    is-result-calc $_, [-14/16, -1], [-29/255], 'Size 33x33';
    # interpolations from ghostscript tracing
    is-result-calc $_, [0.334000, 0.332000], [-0.144925], 'Size 33x33', :rel-tol(0.1);
    is-result-calc $_, [-0.999333, 0.332000], [-0.916298], 'Size 33x33';
    # out by a bit :-|
    is-result-calc $_, [-0.332667, -0.334667,], [-0.474192,], 'Size 33x33', :rel-tol(0.3);
}