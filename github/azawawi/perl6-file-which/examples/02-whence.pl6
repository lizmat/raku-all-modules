#!/usr/bin/env perl6

use v6;
use File::Which :whence;

# All perl executables in PATH
say whence('perl6', :all);

# First executable in PATH
say whence('perl6');
