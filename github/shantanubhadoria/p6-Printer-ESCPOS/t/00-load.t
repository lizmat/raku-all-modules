#!perl6
use v6;
use lib 'lib';

use Test;

use-ok( 'Printer::ESCPOS', 'Printer::ESCPOS' );
use-ok( 'Printer::ESCPOS::Network', 'Printer::ESCPOS::Network' );
use-ok( 'Printer::ESCPOS::Network::Async', 'Printer::ESCPOS::Network::Async' );

done-testing();
