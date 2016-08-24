use v6;

use lib 'lib';;
use Printer::ESCPOS::Network::Async;

await Printer::ESCPOS::Network::Async.connect('10.0.13.108', 9100).then( -> $p {
  if $p.status {
    given $p.result {
      .init;
      .text-size(height => 3, width => 2);
      .barcode("TEST", system => 'CODE93');
      .lf;
      .tab-positions(3,1,2);
      .send('hmargin 1');
      .lf;
      .send('margin 2');
      .lf;

      .cut-paper;
      .lf;
      .close;
    }
  }
});
