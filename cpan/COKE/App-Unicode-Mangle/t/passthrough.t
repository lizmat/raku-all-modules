#!/usr/bin/env perl6

use lib 't';
use runner;

use Test;
plan 1;

mangled 'bold', 'Äî', '𝐀̈𝐢̂', 'passthrough accents'
