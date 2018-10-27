use v6;

use lib 'lib';;
use Printer::ESCPOS::Network;

my $printer = Printer::ESCPOS::Network.new(:host<10.0.13.108>, :port(9100));
$printer.init;
#$printer.text-size(height => 3, width => 2);
$printer.barcode("TEST", system => 'CODE93');
#$printer.lf;
#$printer.tab-positions(3,1,2);
#$printer.line-spacing(86, 'A');
#$printer.send('hmargin 1');
#$printer.lf;
#$printer.send('margin 2');
$printer.lf;

$printer.cut-paper;
#$printer.lf;
$printer.close;
