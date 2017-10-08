use v6;
use Printer::ESCPOS;

class Printer::ESCPOS::Network::Async is IO::Socket::Async is Printer::ESCPOS {
  method send(Str $string) {
    self.print($string);
  }
}
