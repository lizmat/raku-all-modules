use v6;
use Test;

plan 46;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;
use PDF::Grammar::Test :is-json-equiv;

my PDF::Grammar::PDF::Actions $actions .= new;

my $input = q:to"--END-OBJ--";
16 0 obj  % Alternate color space for DeviceN space
[ /CalRGB << /WhitePoint [ 1.0 1.0 1.0 ] >> ]
endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my PDF::IO::IndObj $ind-obj .= new( |%ast);
is $ind-obj.obj-num, 16, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $color-space-obj = $ind-obj.object;
isa-ok $color-space-obj, ::('PDF')::('ColorSpace::CalRGB');
is $color-space-obj.type, 'ColorSpace', '$.type accessor';
is $color-space-obj.subtype, 'CalRGB', '$.subtype accessor';
is-json-equiv $color-space-obj[1], { :WhitePoint[ 1.0, 1.0, 1.0 ] }, 'array dereference';
is-json-equiv $color-space-obj[1]<WhitePoint>, [ 1.0, 1.0, 1.0 ], 'array, hash dereference';
is-json-equiv $color-space-obj.WhitePoint, $color-space-obj[1]<WhitePoint>, '$WhitePoint accessor';
lives-ok {$color-space-obj.check}, '$color-space-obj.check lives';
is-json-equiv $ind-obj.ast, %ast, 'ast regeneration';

require ::('PDF')::('ColorSpace::CalGray');
my $cal-gray = ::('PDF')::('ColorSpace::CalGray').new;
isa-ok $cal-gray, ::('PDF')::('ColorSpace::CalGray'), 'new CS class';
is $cal-gray.subtype, 'CalGray', 'new CS subtype';
isa-ok $cal-gray[1], Hash, 'new CS Dict';

$input = "10 0 obj [/ICCBased << /N 3 /Alternate /DeviceRGB >>] endobj";

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
%ast = $/.ast;
$ind-obj .= new( |%ast);
is $ind-obj.obj-num, 10, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
$color-space-obj = $ind-obj.object;
isa-ok $color-space-obj, ::('PDF')::('ColorSpace::ICCBased');
is $color-space-obj.type, 'ColorSpace', '$.type accessor';
is $color-space-obj.subtype, 'ICCBased', '$.subtype accessor';
is $color-space-obj.N, 3, 'N accessor';
is $color-space-obj.Alternate, 'DeviceRGB', 'DeviceRGB accessor';

$input = "11 0 obj [ /Indexed /DeviceRGB 255 < 000000 FF0000 00FF00 0000FF B57342 > ] endobj";

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
%ast = $/.ast;
$ind-obj .= new( |%ast);
is $ind-obj.obj-num, 11, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
$color-space-obj = $ind-obj.object;
isa-ok $color-space-obj, ::('PDF')::('ColorSpace::Indexed');
is $color-space-obj.type, 'ColorSpace', '$.type accessor';
is $color-space-obj.subtype, 'Indexed', '$.subtype accessor';
is $color-space-obj.Base, 'DeviceRGB', 'Base accessor';
is $color-space-obj.Lookup, "\x[00]\x[00]\x[00]\x[FF]\x[00]\x[00]\x[00]\x[FF]\x[00]\x[00]\x[00]\x[FF]\x[B5]\x[73]\x[42]", 'Lookup accessor';

$input = q:to"--END-OBJ--";
5 0 obj  % Color space
[ /Separation
  /LogoGreen
  /DeviceCMYK
  12 0 R
]
endobj
--END-OBJ--

my $reader = class { has $.auto-deref = False }.new;
PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
%ast = $/.ast;
$ind-obj .= new( |%ast, :$reader);
is $ind-obj.obj-num, 5, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
$color-space-obj = $ind-obj.object;
isa-ok $color-space-obj, ::('PDF')::('ColorSpace::Separation');
is $color-space-obj.type, 'ColorSpace', '$.type accessor';
is $color-space-obj.subtype, 'Separation', '$.subtype accessor';
is $color-space-obj.Name, 'LogoGreen', 'Name accessor';
is $color-space-obj.AlternateSpace, 'DeviceCMYK', 'AlternateSpace accessor';
is-json-equiv $color-space-obj.TintTransform, (:ind-ref[12, 0]), 'TintTransform accessor';

$input = q:to"--END-OBJ--";
30 0 obj    % Color space
[ /DeviceN
  [ /Orange /Green /None ]
  /DeviceCMYK
  1 0 R
  << /Colorants
    << /Orange        [ /Separation /Orange /DeviceCMYK 2 0 R ]
       /Green         [ /Separation /Green /DeviceCMYK 3 0 R ]
       /PANTONE#20131 [ /Separation /PANTONE#20131 /DeviceCMYK 4 0 R ]
    >>
  >>
] endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
%ast = $/.ast;
$ind-obj .= new( |%ast, :$reader);
$color-space-obj = $ind-obj.object;
isa-ok $color-space-obj, ::('PDF')::('ColorSpace::DeviceN');
is-json-equiv $color-space-obj.TintTransform, (:ind-ref[1, 0]), 'TintTransform accessor';
is-json-equiv $color-space-obj.Names, [ <Orange Green None> ], 'Names Accessor';
my $attributes = $color-space-obj.Attributes;
ok $attributes, 'Attributes accessor';
my $colorants = $attributes.Colorants;
ok $colorants, 'Attributes.Colorants sub-accessor';
my $orange-seperation = $colorants<Orange>;
is-json-equiv $orange-seperation, [ 'Separation', 'Orange', 'DeviceCMYK',  :ind-ref[2, 0] ], 'seperation (Orange)';
does-ok $orange-seperation, ::('PDF')::('ColorSpace::Separation'), 'seperation (Orange)';

# build from scratch
use PDF::Function::Exponential;
my PDF::Function::Exponential $exp-func .= new: :dict{ :Domain[ 0, 1], :Range[flat (0.0, 1.0) xx 4], :C0[0.0 xx 4], :C1[0.85, 0.24, 0.0, 0.0], :N(1.0) };
is $exp-func.FunctionType, 2, '$exp-func.FunctionType';
my $cs1 = ::('PDF')::('ColorSpace::Separation').new: :array[ 'Separation', 'My Spot 1', :name<DeviceCMYK>, $exp-func ];
is $cs1.Name, 'My Spot 1', 'cs1.Name';
does-ok $cs1.Name,::('PDF::COS::Name'), 'cs1.Name';
is-deeply $cs1.TintTransform, $exp-func, 'cs1.TintTransform';

