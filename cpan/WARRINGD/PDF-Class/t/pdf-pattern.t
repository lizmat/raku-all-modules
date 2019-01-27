use v6;
use Test;

plan 8;

use PDF::Class;
use PDF::IO::IndObj;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

my PDF::Grammar::PDF::Actions $actions .= new;

# example taken from PDF 1.7 Specification

my $input = q:to"--END-OBJ--";
15 0 obj << % Pattern definition
  /Type /Pattern
  /PatternType 1  % Tiling pattern
  /PaintType 1    % Colored
  /TilingType 2
  /BBox [ 0 0 100 100 ]
  /XStep 100
  /YStep 100
  /Resources << >>
  /Matrix [ 0.4 0.0 0.0 0.4 0.0 0.0 ]
  /Length 183
>> endobj
--END-OBJ--

PDF::Grammar::PDF.parse($input, :$actions, :rule<ind-obj>)
    // die "parse failed";
my %ast = $/.ast;
my PDF::IO::IndObj $ind-obj .= new( |%ast, :$input);
is $ind-obj.obj-num, 15, '$.obj-num';
is $ind-obj.gen-num, 0, '$.gen-num';
my $pattern-obj = $ind-obj.object;
isa-ok $pattern-obj, ::('PDF')::('Pattern::Tiling');
is $pattern-obj.Type, 'Pattern', '$.Type accessor';
is-json-equiv $pattern-obj.BBox, [ 0, 0, 100, 100 ], '$.BBox accessor';
my $zfont = $pattern-obj.core-font('ZapfDingbats');
# example from [PDF 1.7 Example 4.24]
$pattern-obj.gfx.ops: [
    'q',
    'BT',                              # Begin text object
    :Tf[$pattern-obj.resource-key($zfont), 1],                # Set text font and size
    :Tm[64, 0, 0, 64, 7.1771, 2.4414], # Set text matrix
    :Tc[0],                            # Set character spacing
    :Tw[0],                            # Set word spacing

    :rg[1.0, 0.0, 0.0],                # Set nonstroking color to red
    :Tj($zfont.encode("♠", :str)),     # Show spade glyph

    :TD[0.7478, -0.007],               # Move text position
    :rg[0.0, 1.0, 0.0],                # Set nonstroking color to green
    :Tj($zfont.encode("♥", :str)),     # Show heart glyph

    :TD[-0.7323, 0.7813],              # Move text position
    :rg[0.0, 0.0, 1.0],                # Set nonstroking color to blue
    :Tj($zfont.encode("♦", :str)),     # Show diamond glyph

    :TD[0.6913, 0.007],                # Move text position
    :rg[0.0, 0.0, 0.0],                # Set nonstroking color to black
    :Tj($zfont.encode("♣", :str)),     # Show club glyph
    'ET',                              # End text object
    'Q',
    ];

$pattern-obj.cb-finish;
lives-ok {$pattern-obj.check}, '$pattern-obj.check lives';

my $contents = $pattern-obj.decoded;
my @lines = $contents.lines;
is-deeply [ @lines[0..2] ], ['q', '  BT', '    /F1 1 Tf'], 'first three lines of content';
is-deeply [ @lines[*-4..*] ], ['    0 0 0 rg', '    (¨) Tj', '  ET', 'Q'], 'last 5 lines of content';

my PDF::Class $pdf .= new;
my $page = $pdf.Pages.add-page;
$page.media-box = [0, 0, 230, 210];
$page.gfx.ops: [
    :q[],                                       # Graphics save
    :G[0.0],                                    # Set stroking color to black
    :rg[1.0, 1.0, 0.0],                         # Set nonstroking color to yellow
    :re[25, 175, 175, -150],                    # Construct rectangular path
    :f[],                                       # Fill path
    :cs[<Pattern>],                             # Set pattern color space
    :scn[$page.resource-key($pattern-obj)],     # Set pattern as nonstroking color

    :m[99.92, 49.92],                                # Start new path
    :c[99.92, 77.52, 77.52, 99.92, 49.92, 99.92],    # Construct lower-left circle
    :c[22.32, 99.92, -0.08, 77.52, -0.08, 49.92],
    :c[-0.08, 22.32, 22.32, -0.08, 49.92, -0.08],
    :c[77.52, -0.08, 99.92, 22.32, 99.92, 49.92],
    :B[],                                            # Fill and stroke path

    :m[224.96, 49.92],                               # Start new path
    :c[224.96, 77.52, 202.56, 99.92, 174.96, 99.92], # Construct lower-right circle
    :c[147.36, 99.92, 124.96, 77.52, 124.96, 49.92],
    :c[124.96, 22.32, 147.36, -0.08, 174.96, -0.08],
    :c[202.56, -0.08, 224.96, 22.32, 224.96, 49.92],
    :B[],                                            # Fill and stroke path

    :m[87.56, 201.70],                               # Start new path
    :c[63.66, 187.90, 55.46, 157.32, 69.26, 133.40], # Construct upper circle
    :c[83.06, 109.50, 113.66, 101.30, 137.56, 115.10],
    :c[161.46, 128.90, 169.66, 159.50, 155.86, 183.40],
    :c[142.06, 207.30, 111.46, 215.50, 87.56, 201.70],
    :B[],                                            # Fill and stroke path

    :m[50, 50],         # Start new path
    :l[175, 50],        # Construct triangular path
    :l[112.5, 158.253],
    :b[],               # Close, fill, and stroke path
    :Q[],               # Graphics restore
    ];

# ensure consistant document ID generation
srand(123456);

$pdf.save-as('t/pdf-pattern.pdf', :!info);
