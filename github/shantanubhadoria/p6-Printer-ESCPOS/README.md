NAME
====

Printer::ESCPOS - Interface to ESCPOS printers

SYNOPSIS
========

Network printer in asynchronous mode
------------------------------------

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

Network printer in synchronous mode
-----------------------------------

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

DESCRIPTION
===========

ESC/P, short for Epson Standard Code for Printers and sometimes styled Escape/P, is a printer control language developed by Epson to control computer printers. It was mainly used in dot matrix printers and some inkjet printers, and is still widely used in many receipt printers. During the era of dot matrix printers, it was also used by other manufacturers (e.g. NEC), sometimes in modified form. At the time, it was a popular mechanism to add formatting to printed text, and was widely supported in software. These days its almost a standard communication mode for talking to thermal and dot-matrix receipt printers used for printing bills, receipts etc. in retail outlets, restaurants etc. There are several variants of ESC/P, as not all printers implement all commands. Epson refers to a more recent variant of ESC/P as ESC/P2. ESC/P2 is backward compatible with ESC/P, but adds commands for new printer features such as scalable fonts and enhanced graphics printing.

ADDING A CONNECTION CLASS
=========================

Perl 6 classes allow easy extendability of the Printer::ESCPOS to support newer communication ports/protocols. See below examples for examples of how I have added TCP IP support(for Async and Synchronous modes):

Extending IO::Socket::INET in just 4 lines of code:
---------------------------------------------------

IO::Socket::INET allows synchronous communication with a TCP device. Watch how we can use this module to talk to ESCPOS printers in just 4 lines of code.

    use v6;
    use Printer::ESCPOS;

    class Printer::ESCPOS::Network is IO::Socket::INET is Printer::ESCPOS {
      method send(Str $string) { # Send is the subroutine called by Printer::ESCPOS to send data to the Printer
                                 # Since IO::Socket::INET uses print() method to send data to the peer. We route data
                                 # Sent on send() to IO::Socket::INET's print() method.
        self.print($string);
      }
    }

Now you can use Printer::ESCPOS::Network class to talk to any network printer:

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

Extending IO::Socket::Async in just 4 lines of code:
----------------------------------------------------

IO::Socket::Async allows asynchronous communication with a TCP device. Watch how we can use this module to talk to ESCPOS printers in just 4 lines of code.

    use v6;
    use Printer::ESCPOS;

    class Printer::ESCPOS::Network::Async is IO::Socket::Async is Printer::ESCPOS {
      method send(Str $string) {
        self.print($string);
      }
    }

Now you can use Printer::ESCPOS::Network::Async class to talk to any network printer:

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

ATTRIBUTES
==========

At the moment the attributes used are dependent on the communication protocol/port that you use. If your Printer is connected over a network you will need to provide a IP Address and port number. At the moment only network driver is supported. USB, Serial and Bluetooth support will be added as Modules for the same become available in Perl 6

    use Printer::ESCPOS;

    class Printer::ESCPOS::Network::Async is IO::Socket::Async is Printer::ESCPOS {
      method send(Str $string) {
        self.print($string);
      }
    }

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

METHODS
=======

init
----

Initializes the Printer. Clears the data in print buffer and resets the printer to the mode that was in effect when the power was turned on. This function is automatically called on creation of printer object.

SUPPORT
=======

Bugs / Feature Requests
-----------------------

Please report any bugs or feature requests through github at [https://github.com/shantanubhadoria/p6-printer-escpos/issues](https://github.com/shantanubhadoria/p6-printer-escpos/issues). You will be notified automatically of any progress on your issue.

Source Code
-----------

This is open source software. The code repository is available for public review and contribution under the terms of the license.

[https://github.com/shantanubhadoria/p6-printer-escpos](https://github.com/shantanubhadoria/p6-printer-escpos)

    git clone git://github.com/shantanubhadoria/p6-printer-escpos.git

AUTHOR
======

Shantanu Bhadoria <shantanu@cpan.org> [https://www.shantanubhadoria.com](https://www.shantanubhadoria.com)

COPYRIGHT AND LICENSE
=====================

This software is copyright (c) 2016 by Shantanu Bhadoria.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 6 programming language system itself.
