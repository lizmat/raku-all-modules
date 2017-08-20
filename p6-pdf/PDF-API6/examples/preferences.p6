use v6;
use PDF::API6;

my PDF::API6 $pdf .= new;
my $page;

for 1..2 -> $page-no {
    $page = $pdf.add-page;
    $page.MediaBox = [0, 0, 450, 400];
    $page.text: {
        .font = .core-font( :family<Courier>, :weight<bold> );
        .TextMove = [10, 350];

        .say: "Page $page-no/2";
        .say;
        .say: "This PDF have preferences:";
        .say: " :hide-toolbar (toolbar should not appear in reader)";
        .say: " :page(2)      (document should open on page 2)";
        .say: " :fit          (contents should scale to fit window)";
    }
}

$pdf.preferences: :hide-toolbar, :first-page{ :$page, :fit };
$pdf.save-as: "preferences.pdf";


