use v6;
use Test;
plan 3;
use PDF::API6;
use PDF::Destination :Fit;

my PDF::API6 $pdf .= new;

$pdf.add-page for 1 .. 5;
my PDF::Destination['Fit'] $dest;

lives-ok { $dest = $pdf.destination(:page(2))}, 'fit destination';

ok $dest.page === $pdf.page(2), 'fit dest page ref';
is $dest.fit, 'Fit', 'destination fit';

$pdf.save-as: "tmp/outlines.pdf";

done-testing;