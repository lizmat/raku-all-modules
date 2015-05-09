#!/usr/bin/.env perl6

use lib 'lib';
use Test;

plan 1;

use Event::Emitter;

ok True, 'Didn\'t die on use';
