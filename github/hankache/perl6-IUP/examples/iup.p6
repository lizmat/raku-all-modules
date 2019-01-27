#!/usr/bin/env perl6

use lib 'lib';

use IUP;

my $iup = IUP.new();

my @argv = ("Test");
$iup.open(@argv);

$iup.dialog(
	$iup.label("Hello, world!")
).show();

$iup.main_loop();
$iup.close();

exit();
