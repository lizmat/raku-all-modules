use v6;
use Test;

# ensure consistant document ID generation
srand(123456);

use PDF::Lite;
use PDF::Grammar::Test :is-json-equiv;
my PDF::Lite $pdf .= new;
my $page = $pdf.add-page;
my $header-font = $page.core-font( :family<Helvetica>, :weight<bold> );

$page.text: {
    .text-position = [200, 200];
    .font = [$header-font, 18];
    .say(:width(250),
	"Lorem ipsum dolor sit amet, consectetur adipiscing elit,
         sed do eiusmod tempor incididunt ut labore et dolore
         magna aliqua");
}

$page.graphics: {
    my $img = .load-image: "t/images/lightbulb.gif";
    .do($img, 100, 100);
}

# deliberately leave the PDF in an untidy graphics state
# should wrap this in 'q' .. 'Q' when re-read
$page.gfx.strict = False;
$page.gfx.SetStrokeRGB(.3, .4, .5);
is-json-equiv $page.gfx.content-dump[0..6], (
    "BT",
    "1 0 0 1 200 200 Tm",
    "/F1 18 Tf",
    "(Lorem ipsum dolor sit amet,) Tj",
    "19.8 TL",
    "T*",
    "(consectetur adipiscing elit,) Tj",
    ),
    'presave graphics (head)';

lives-ok { $pdf.save-as("t/01-pdf-lite.pdf") }, 'save-as';

throws-like { $pdf.unknown-method }, X::Method::NotFound, '$pdf unknown method';

lives-ok { $pdf = PDF::Lite.open("t/01-pdf-lite.pdf") }, 'open';
is-json-equiv $pdf.page(1).gfx.content-dump[0..6], (
    "q",
    "BT",
    "1 0 0 1 200 200 Tm",
    "/F1 18 Tf",
    "(Lorem ipsum dolor sit amet,) Tj",
    "19.8 TL",
    "T*",
    ), 'reloaded graphics (head)';

is-json-equiv $pdf.page(1).gfx.ops[*-2..*], (
    :RG[:real(.3), :real(.4), :real(.5)],
    :Q[],), 'reloaded graphics (tail)';

done-testing;
