use PDF::API6;
use Test;
use PDF::ColorSpace::Separation;
use PDF::Function::Sampled;
use PDF::Content::Color :color;
plan 5;

my PDF::API6 $pdf .= new;
my $gfx = $pdf.add-page.gfx;
my $cyan = $pdf.color-separation('Cyan', color '%f000');
isa-ok $cyan, PDF::ColorSpace::Separation;
is $cyan[0], 'Separation';
is $cyan[1], 'Cyan';
is $cyan[2], 'DeviceCMYK';
isa-ok $cyan[3], PDF::Function::Sampled;

my $magenta = $pdf.color-separation('Magenta', color '%0f00');
my $yellow = $pdf.color-separation('Yellow', color '%00f0');
my $black = $pdf.color-separation('Black', color '%000f');
my $pms023 = $pdf.color-separation('PANTONE 032CV', color '%0ff0');
my $green-rgb = $pdf.color-separation('Green', color '#0f0');

my $device-n = $pdf.color-devicen([$cyan, $magenta, $yellow, $black, $pms023]);

$gfx.graphics: {
    .text: {
        .text-position = (50, 600);

        .print: "Normal Gray --> ";
        .FillColor = $black => 1;
        .say: " (separation)";

        .FillColor = $cyan => 1;
        .print: "Cyan (100%) --> ";
        .FillColor = $cyan => .40;
        .say: " (40%)";

        .FillColor = $pms023 => 1;
        .print: "PMS Color --> ";
        .FillColor = color '%0ff0';
        .say: "(CMYK)";

        .FillColor = :DeviceRGB[0, 1, 0];
        .print: "Green (regular) --> ";
        .FillColor = $green-rgb => 1;
        .say: " (separation)";

        .FillColor = :DeviceCMYK[1, 1, 0, .2];
        .print: "Blue (regular) --> ";
        .FillColor = $device-n => [1, 1, 0, .2, 0];
        .say: " (devicen)";
    }
}

$pdf.save-as: "t/colors.pdf";

