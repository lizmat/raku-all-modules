use v6;
use Test;
use PDF::Class;
use PDF::Grammar::Test :$is-json-equiv;
use PDF::Catalog;
use PDF::Annot::Widget;
use PDF::Field;
my $pdf;

lives-ok {$pdf = PDF::Class.open("t/pdf/samples/OoPdfFormExample.pdf")}, "open form example  lives";
my $annots = $pdf.page(1).Annots;
isa-ok $annots[0], PDF::Annot::Widget, 'page annots';
does-ok $annots[0], PDF::Field, 'page annots';

does-ok $pdf.page(1).fields[0], PDF::Field, 'page fields accessor';

my $doc = $pdf.Root;
isa-ok $doc, PDF::Catalog, 'document root';

my $acroform = $doc.AcroForm;
does-ok $doc.AcroForm, ::('PDF::AcroForm');

lives-ok {$doc.OpenAction}, '$doc.OpenAction';
does-ok $doc.OpenAction, ::('PDF::Action::Destination');

my @fields = $acroform.fields;
isa-ok @fields, Array, '.Fields';
is +@fields, 17, 'fields count';
does-ok @fields[0], (require ::('PDF::Field')), '.Fields';
isa-ok @fields[0], (require ::('PDF::Annot::Widget')), 'field type';

is @fields[0].Type, 'Annot', 'Type';
is @fields[0].Subtype, 'Widget', 'Subtype';
is @fields[0].F, 4, '.F';
is @fields[0].FT, 'Tx', '.FT';
is @fields[0].type, 'Tx', '.type';
isa-ok @fields[0]<P>, ::('PDF::Page'), '<P>';
my $page = @fields[0].P;
isa-ok $page, ::('PDF::Page'), '.P';
is-json-equiv @fields[0].Rect, [165.7, 453.7, 315.7, 467.9], '.Rect';
is @fields[0].T, 'Given Name Text Box', '.T';
is @fields[0].TU, 'First name', '.TU';
is @fields[0].V, '', '.V';
is (try @fields[0].key), 'Given Name Text Box', '.key';
is (try @fields[0].value), '', '.value';
is @fields[0].DV, '', '.DV';
is @fields[0].MaxLen, 40, '.MaxLen';
isa-ok @fields[0].DR, Hash, '.DR';
ok @fields[0].DR<Font>:exists, '.DR<Font>';
is @fields[0].DA, '0 0 0 rg /F3 11 Tf', '.DA';
my $appearance = @fields[0].AP;
isa-ok $appearance, Hash, '.AP';
does-ok $appearance, (require ::('PDF::Appearance')), '.AP';
isa-ok $appearance.N, (require ::('PDF::XObject::Form')), '.AP.N';
ok $page.Annots[0] === @fields[0], 'first field via page-1 annots';

my $country = @fields[5];
does-ok $country, (require ::('PDF::Field::Choice')), 'choice field';
is +$country.Opt, 28, 'choice options';
is $country.Opt[0], 'Austria', 'choice first option';

my $languages = @fields[8];
does-ok $languages, ::('PDF::Field::Button'), 'Button field';
$appearance = $languages.AP;
does-ok $appearance, (require ::('PDF::Appearance')), '.AP';
isa-ok $appearance.N.Yes, ::('PDF::XObject::Form'), '.AP.N.Yes';

my %fields = $acroform.fields-hash;
is +%fields, 17, 'fields hash key count';
ok %fields{'Given Name Text Box'} == @fields[0], 'field hash lookup by .T';

# check meta-data
use PDF::Reader;
isa-ok $doc.reader, PDF::Reader, '$doc.reader';
isa-ok $doc.AcroForm.reader, PDF::Reader, '$doc.AcroForm.reader';
isa-ok @fields[0].reader, PDF::Reader, '$doc.AcroForm.Fields[0].reader';
is @fields[0].obj-num, 5, '.obj-num';
is @fields[0].gen-num, 0, '.gen-num';
isa-ok @fields[0].P.reader, PDF::Reader, '$doc.AcroForm.Fields[0].P.reader';

done-testing;
