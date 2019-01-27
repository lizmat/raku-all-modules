#!/usr/bin/env perl6

use lib 'lib';

use IUP;

my $iup = IUP.new();

my @argv = ("Test");
$iup.open(@argv);

my $ih = IUP::Handle.new();

$ih.message("IupMessage Example", "Press the button");

$iup.close();

exit();
