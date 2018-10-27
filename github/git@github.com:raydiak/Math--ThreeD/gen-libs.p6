#!/usr/bin/env perl6

use v6;

chdir $?FILE.IO.dirname;

require('gen-vec3.p6'.IO.absolute);
require('gen-mat44.p6'.IO.absolute);

# vim: set expandtab:ts=4:sw=4
