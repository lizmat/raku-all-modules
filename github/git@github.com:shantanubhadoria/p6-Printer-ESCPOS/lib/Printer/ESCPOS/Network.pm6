use v6;
use Printer::ESCPOS;

class Printer::ESCPOS::Network is IO::Socket::INET is Printer::ESCPOS {
  method send(Str $string) {
    self.print($string);
  }
}
