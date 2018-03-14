use v6;
use Test;
use PDF::Class;
use PDF::Grammar::Test :is-json-equiv;

my $doc = PDF.open: "t/pdf/colorspace-devicen.in";
my %cs = $doc.Root.Pages.resources: 'ColorSpace';

my $cs1 = %cs<CS1>;
does-ok $cs1, ::('PDF::ColorSpace::DeviceN');
is $cs1.type, 'ColorSpace', '.type Accessor';
is $cs1.Subtype, 'DeviceN', '.Subtype Accessor';
is $cs1.Names[1], 'Magenta', '.Names[1]';
is $cs1.AlternateSpace, 'DeviceCMYK', '.AlternateSpace accessor';

my $tint-transform = $cs1.TintTransform;
isa-ok $tint-transform, ::('PDF::Function::Sampled');

is $tint-transform.BitsPerSample, 8, '.TintTransform.BitsPerSample';
is $tint-transform.Length, 257, '.TintTransform.Length';

my $atts;
lives-ok {$atts = $cs1.Attributes}, '.Attributes accessor';

my $colorants = $atts.Colorants;
isa-ok $colorants, ::('PDF::COS::Dict'), 'Colorants';
my $magenta = $colorants<Magenta>;
isa-ok $magenta, ::('PDF::ColorSpace::Separation'), '.Colorants<Magenta>';
is $magenta.Name, 'Magenta',  '.Colorants<Magenta>.Name';

$tint-transform = $magenta.TintTransform;
isa-ok $tint-transform, ::('PDF::Function::Sampled');
is-json-equiv $tint-transform.Domain, [0, 1], '.Colorants<Magenta>.TintTransform';
is $tint-transform.decoded, "\x[0]" x 4 ~ "\x[ff]" x 4, ".Colorants<Magenta>.TintTransform.decoded"; 

done-testing;
