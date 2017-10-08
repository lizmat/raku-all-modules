#!perl6

use v6.c;

use Test;

use-ok('Audio::Hydrogen::Instrument', 'load Instrument ok');
use-ok('Audio::Hydrogen::Drumkit', 'load Drunkit ok');
use-ok('Audio::Hydrogen::Pattern', 'load Pattern ok');
use-ok('Audio::Hydrogen::Song', 'load Song ok');


done-testing;
# vim: expandtab shiftwidth=4 ft=perl6
