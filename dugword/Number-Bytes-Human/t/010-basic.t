#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Test;

use Number::Bytes::Human;

plan 1;

ok True, "No exception thrown on module load";

done-testing;
