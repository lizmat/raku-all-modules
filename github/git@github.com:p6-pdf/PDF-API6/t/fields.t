use v6;
use Test;
plan 29;
use PDF::API6;
use PDF::Page;
use PDF::Field;
use PDF::Annot::Widget;
use PDF::Appearance;
use PDF::XObject::Form;
use PDF::Grammar::Test :is-json-equiv;
use PDF::Annot::Widget;

my PDF::API6 $pdf .= open("t/pdf/OoPdfFormExample.pdf");

my $annots = $pdf.page(1).Annots;
isa-ok $annots[0], PDF::Annot::Widget, 'page annots';
does-ok $annots[0], PDF::Field, 'page annots';

my @fields = $pdf.fields;
isa-ok @fields, Array, '.Fields';
is +@fields, 17, 'fields count';
does-ok @fields[0], PDF::Field, '.Fields';
isa-ok @fields[0], PDF::Annot::Widget, 'field type';

my $page = @fields[0].page;
isa-ok $page, PDF::Page, '.page';
is-json-equiv @fields[0].Rect, [165.7, 453.7, 315.7, 467.9], '.Rect';
is @fields[0].key, 'Given Name Text Box', '.T';
is @fields[0].label, 'First name', '.TU';
is @fields[0].value, '', '.V';
is (try @fields[0].key), 'Given Name Text Box', '.key';
is (try @fields[0].value), '', '.value';
is @fields[0].default-value, '', '.default-value';
is @fields[0].MaxLen, 40, '.MaxLen';
isa-ok @fields[0].DR, Hash, '.DR';
is @fields[0].default-appearance, '0 0 0 rg /F3 11 Tf', '.DA';
my $appearance = @fields[0].appearance;
isa-ok $appearance, Hash, '.appearance';
does-ok $appearance, PDF::Appearance, '.appearance';
does-ok $appearance.N, PDF::XObject::Form, '.apperance.N';
ok $page.Annots[0] === @fields[0], 'first field via page-1 annots';

my $country = @fields[5];
does-ok $country, (require ::('PDF::Field::Choice')), 'choice field';
is +$country.Opt, 28, 'choice options';
is $country.Opt[0], 'Austria', 'choice first option';

my $languages = @fields[8];
does-ok $languages, ::('PDF::Field::Button'), 'Button field';
$appearance = $languages.AP;
does-ok $appearance, (require ::('PDF::Appearance')), '.AP';
isa-ok $appearance.N.Yes, PDF::XObject::Form, '.AP.N.Yes';

my %fields = $pdf.fields-hash;
is +%fields, 17, 'fields hash key count';
ok %fields{'Given Name Text Box'} == @fields[0], 'field hash lookup by .T';

done-testing;