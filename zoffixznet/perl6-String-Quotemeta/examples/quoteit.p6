#!/usr/bin/env perl6

use lib 'lib';
use String::Quotemeta;

@*ARGS or die "Usage: app.pl Stuff To Quotemeta";
say quotemeta for @*ARGS;
