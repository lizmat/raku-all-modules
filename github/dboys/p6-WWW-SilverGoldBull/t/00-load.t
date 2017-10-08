#!perl6

use v6;

use lib 'lib';
use Test;

use-ok('WWW::SilverGoldBull');
use-ok('WWW::SilverGoldBull::Order');
use-ok('WWW::SilverGoldBull::Quote');
use-ok('WWW::SilverGoldBull::Response');
use-ok('WWW::SilverGoldBull::Address');
use-ok('WWW::SilverGoldBull::Types');
use-ok('WWW::SilverGoldBull::Item');

done-testing;
