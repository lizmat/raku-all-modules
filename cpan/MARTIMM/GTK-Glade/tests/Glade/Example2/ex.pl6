#!/usr/bin/env perl6

use v6;

use nqp;
use NativeCall;
use GTK::Simple::Raw :app, :DEFAULT;

my $arg_arr = CArray[Str].new;
$arg_arr[0] = $*PROGRAM.Str;
my $argc = CArray[int32].new;
$argc[0] = 1;
my $argv = CArray[CArray[Str]].new;
$argv[0] = $arg_arr;
gtk_init($argc, $argv);
