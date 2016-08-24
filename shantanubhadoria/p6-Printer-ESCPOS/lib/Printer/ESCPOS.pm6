use v6;

=begin pod

=head1 NAME

Printer::ESCPOS - Interface to ESCPOS printers

=head1 SYNOPSIS

=head2 Network printer in asynchronous mode

=begin code

    use Printer::ESCPOS::Network::Async;

    // Asynchronous control over your network ESCPOS printer
    await Printer::ESCPOS::Network::Async.connect('10.0.13.108', 9100).then( -> $p {
      if $p.status {
        given $p.result {
          .init;
          .barcode("TEST", system => 'CODE93');
          .lf;
          .tab-positions(3,1,2);
          $printer.tab;
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

=end code

=head2 Network printer in synchronous mode

=begin code

    use Printer::ESCPOS::Network;

    my $printer = Printer::ESCPOS::Network.new(:host<10.0.13.108>, :port(9100));
    $printer.init;
    $printer.barcode("TEST", system => 'CODE93');
    $printer.lf;
    $printer.tab-positions(3,1,2);
    $printer.tab;
    $printer.send('hmargin 1');
    $printer.lf;
    $printer.send('margin 2');
    $printer.lf;

    $printer.cut-paper;
    $printer.lf;
    $printer.close;

=end code

=head1 DESCRIPTION

ESC/P, short for Epson Standard Code for Printers and sometimes styled Escape/P, is a printer control language developed
by Epson to control computer printers. It was mainly used in dot matrix printers and some inkjet printers, and is still
widely used in many receipt printers. During the era of dot matrix printers, it was also used by other manufacturers
(e.g. NEC), sometimes in modified form. At the time, it was a popular mechanism to add formatting to printed text, and
was widely supported in software. These days its almost a standard communication mode for talking to thermal and
dot-matrix receipt printers used for printing bills, receipts etc. in retail outlets, restaurants etc. There are several
variants of ESC/P, as not all printers implement all commands. Epson refers to a more recent variant of ESC/P as ESC/P2.
ESC/P2 is backward compatible with ESC/P, but adds commands for new printer features such as scalable fonts and enhanced
graphics printing.

=head1 ADDING A CONNECTION CLASS

Perl 6 classes allow easy extendability of the Printer::ESCPOS to support newer communication ports/protocols. See
below examples for examples of how I have added TCP IP support(for Async and Synchronous modes):

=head2 Extending IO::Socket::INET in just 4 lines of code:

IO::Socket::INET allows synchronous communication with a TCP device. Watch how we can use this module to talk to ESCPOS
printers in just 4 lines of code.

=begin code

use v6;
use Printer::ESCPOS;

class Printer::ESCPOS::Network is IO::Socket::INET is Printer::ESCPOS {
  method send(Str $string) { # Send is the subroutine called by Printer::ESCPOS to send data to the Printer
                             # Since IO::Socket::INET uses print() method to send data to the peer. We route data
                             # Sent on send() to IO::Socket::INET's print() method.
    self.print($string);
  }
}

=end code

Now you can use Printer::ESCPOS::Network class to talk to any network printer:

=begin code

use Printer::ESCPOS::Network;

my $printer = Printer::ESCPOS::Network.new(:host<10.0.13.108>, :port(9100));
$printer.init;
$printer.barcode("TEST", system => 'CODE93');
$printer.lf;
$printer.tab-positions(3,1,2);
$printer.tab;
$printer.send('hmargin 1');
$printer.lf;
$printer.send('margin 2');
$printer.lf;

$printer.cut-paper;
$printer.lf;
$printer.close;

=end code

=head2 Extending IO::Socket::Async in just 4 lines of code:

IO::Socket::Async allows asynchronous communication with a TCP device. Watch how we can use this module to talk to
ESCPOS printers in just 4 lines of code.

=begin code

use v6;
use Printer::ESCPOS;

class Printer::ESCPOS::Network::Async is IO::Socket::Async is Printer::ESCPOS {
  method send(Str $string) {
    self.print($string);
  }
}


=end code

Now you can use Printer::ESCPOS::Network::Async class to talk to any network printer:

=begin code

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


=end code

=head1 ATTRIBUTES

At the moment the attributes used are dependent on the communication protocol/port that you use. If your Printer is
connected over a network you will need to provide a IP Address and port number. At the moment only network driver is
supported. USB, Serial and Bluetooth support will be added as Modules for the same become available in Perl 6

=begin code

use Printer::ESCPOS;

class Printer::ESCPOS::Network::Async is IO::Socket::Async is Printer::ESCPOS {
  method send(Str $string) {
    self.print($string);
  }
}

=end code

=begin code

use Printer::ESCPOS::Network::Async;

await Printer::ESCPOS::Network::Async.connect('10.0.13.108', 9100).then( -> $p {
  if $p.status {
    given $p.result {
      .init;
      .barcode("TEST", system => 'CODE93');
      .lf;
      .send('hmargin 1');
      .lf;
      .cut-paper;
      .close;
    }
  }
});

=end code

=head1 METHODS

=head2 init

Initializes the Printer. Clears the data in print buffer and resets the printer to the mode that was in effect when the
power was turned on. This function is automatically called on creation of printer object.

=head1 SUPPORT

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through github at
L<https://github.com/shantanubhadoria/p6-printer-escpos/issues>.
You will be notified automatically of any progress on your issue.

=head2 Source Code

This is open source software.  The code repository is available for
public review and contribution under the terms of the license.

L<https://github.com/shantanubhadoria/p6-printer-escpos>

  git clone git://github.com/shantanubhadoria/p6-printer-escpos.git

=head1 AUTHOR

Shantanu Bhadoria <shantanu@cpan.org> L<https://www.shantanubhadoria.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Shantanu Bhadoria.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 6 programming language system itself.

=end pod

class Printer::ESCPOS:auth<github:shantanubhadoria>:ver<1.0.1> {

  subset Byte of Int where {
    0 <= $_ and $_ <= 255 or warn 'Byte must be a Int between 0 and 255';
  };

  subset Font of Int where {
    0 <= $_ <= 2 or warn 'Font must be a Int 0, 1 or 2';
  };

  subset HalfByte of Int where {
    0 <= $_ and $_ <= 15 or warn 'HalfByte must be a Int between 0 and 15';
  };

  subset TwoByte of Int where {
    0 <= $_ and $_ <= 65535 or warn 'Byte must be a Int between 0 and 255';
  };


  # Level 1 constants
  constant ESC = "\x1b";
  constant GS  = "\x1d";
  constant DLE = "\x10";
  constant FS  = "\x1c";

  # Level 2 constants
  constant FF  = "\x0c";
  constant SP  = "\x20";
  constant EOT = "\x04";
  constant DC4 = "\x14";


  class X::Adhoc is Exception {
    has Str $.message;
  }


  enum AlignmentEnum(<left right center full>);
  subset Alignment of Str where {
    lc $_ ∈ AlignmentEnum or warn 'Alignment must be "left", "right", "center" or "full"';
  };
  method align(Alignment $alignment) {
    self.send( ESC ~ 'a' ~ AlignmentEnum.enums{lc $alignment} );
  }

  enum BarcodeTextPositionEnum(<none above below aboveandbelow>);
  subset BarcodeTextPosition of Str where {
    lc $_ ∈ BarcodeTextPositionEnum
      or warn 'Barcode TextPosition must be one of ' ~ BarcodeTextPositionEnum.enums.keys.map({““$_””}).join(', ');
  };
  enum BarcodeSystemEnum(<UPC-A UPC-E JAN13 JAN8 CODE39 ITF CODABAR CODE93 CODE128>);
  subset BarcodeSystem of Str where {
    uc $_ ∈ BarcodeSystemEnum
      or warn 'Barcode System must be one of ' ~ BarcodeSystemEnum.enums.keys.map({““$_””}).join(', ');
  };
  method barcode(
    Str $text,
    BarcodeTextPosition :$textPosition = 'below',
    Font :$font = 0,
    Byte :$height = 50,
    Byte :$width = 2,
    BarcodeSystem :$system = 'CODE93') {
      self.send( GS ~ 'H' ~ chr(BarcodeTextPositionEnum.enums{lc $textPosition}) );
      self.send( GS ~ 'f' ~ chr($font) );
      self.send( GS ~ 'h' ~ chr($height) );
      self.send( GS ~ 'w' ~ chr($width) );
      self.send( GS ~ 'k' ~ chr(BarcodeSystemEnum.enums{uc $system} + 65) );
      self.send( chr($text.chars) ~ $text);
  }

  method beep() {
    self.send( "\x07" );
  }

  method bold(Bool $bold) {
    self.send( ESC ~ 'E' ~ $bold.Numeric ); # Get value for Bool as we need to pass a 1 or 0
  }

  method cancel() {
    self.send( "\x18" );
  }

  method char-spacing(Byte $charSpacing) {
    self.send( ESC ~ SP ~ chr($charSpacing) );
  }

  subset Color of Int where {
    0 <= $_ <= 7 or warn 'Color must be a Int between 0 and 7';
  };
  method color(Color $color) {
    self.send( ESC ~ 'r' ~ chr($color) );
  }

  method cr() {
    self.send( "\x0d" );
  }

  method cut-paper(Bool :$partialCut = False, Bool :$feed = True) {
    self.lf;

    my Int $value = $partialCut.Numeric + 65 × $feed.Numeric;
    self.send( GS ~ 'V' ~ chr(66) ~ chr(1) );
  }

  method double-strike(Bool $doubleStrike) {
    self.send( ESC ~ 'G' ~ $doubleStrike.Numeric ); # Get value for Bool as we need to pass a 1 or 0
  }

  method drawer-kick-pulse(Int :$pin where * ∈ (0, 1) = 0, Int :$time where [1..8] = 8) {
    self.send( DLE ~ DC4 ~ '\x01' ~ chr($pin) ~ chr($time) );
  }

  method enable(Bool $enable) {
    self.send( ESC ~ '=' ~ chr($enable.Numeric) ); # Get value for Bool as we need to pass a 1 or 0
  }

  method ff() {
    self.send( "\x0c" );
  }

  method font(Font $font) {
    self.send( ESC ~ 'M' ~ $font );
  }

  method horizontal-position(TwoByte $horizontalPosition where * < 4096 = 0) {
    my ($nH, $nL) = self!split-bytes($horizontalPosition, 2);
    self.send( ESC ~ '$' ~ chr($nL) ~ chr($nH) );
  }

  method init() {
    self.send( ESC ~ '@' );
  }

  method invert(Bool $invert) {
    self.send( GS ~ 'B' ~ chr($invert.Numeric) ); # Get value for Bool as we need to pass a 1 or 0 ASCII
  }

  method left-margin(TwoByte $leftMargin) {
    my ($nH, $nL) = self!split-bytes($leftMargin, 2);
    self.send( GS ~ 'L' ~ chr($nL) ~ chr($nH) );
  }

  method lf() {
    self.send( "\n" );
  }

  subset LineSpacingCommandSet of Str where {
    $_ ∈ ('+', '3', 'A') or warn 'LineSpacing CommandSet must be "+", "3" or "A"';
  }
  method line-spacing(
    Byte $lineSpacing,
    LineSpacingCommandSet $commandSet where ($commandSet ne 'A' or $lineSpacing <= 85) = '3'
    ) {
    self.send( ESC ~ $commandSet ~ chr($lineSpacing) );
  }

  method print-area-width(TwoByte $width) {
    my ($nH, $nL) = self!split-bytes($width, 2);
    self.send( GS ~ 'W' ~ $nL ~ $nH );
  }

  method rot90(Bool $rot90) {
    self.send( ESC ~ 'V' ~ chr($rot90.Numeric) );
  }

  method tab() {
    self.send( "\t" );
  }

  method tab-positions(*@tabPositions where {$_.any ~~ Int and $_.any > 0}) {
    my $string = ESC ~ 'D';
    for @tabPositions.sort -> $tabPosition {
      $string ~= chr($tabPosition);
    }
    self.send($string);
  }

  method text-size(HalfByte :$height!, HalfByte :$width!) {
    my $size = $width +< 4 +| $height;
    self.send( GS ~ '!' ~ chr($size) );
  }

  subset Underline of Int where {
    0 <= $_  <= 2 or warn 'Underline must be a Int 0, 1 or 2';
  };
  method underline(Underline $underLine) {
    self.send( ESC ~ '-' ~ $underLine );
  }

  method upside-down(Bool $upsideDown) {
    self.send( ESC ~ '{' ~ $upsideDown.Numeric );  # Get value for Bool as we need to pass a 1 or 0
  }

  method !split-bytes(Int $value is copy, Int $minBytes = 0) {
    my @byteArray = [];
    while ($value != 0 or (@byteArray.elems) < $minBytes) {
      @byteArray.unshift($value +& 255);
      $value +>= 8;
    }
    return @byteArray;
  }
}
