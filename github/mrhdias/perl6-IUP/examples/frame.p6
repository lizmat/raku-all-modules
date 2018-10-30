#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use IUP;

sub MAIN() {

	my $iup = IUP.new();

	my @argv = ("Test");
	#
	# Initializes IUP
	#
	$iup.open(@argv);

	my $ih = IUP::Handle.new();

	#
	# Creates frame with a label
	#
	my $frame = $ih.frame(
		$ih.hbox(
			$ih.fill(),
			$ih.label("IupFrame Attributes:\nFGCOLOR = \"255 0 0\"\nSIZE = \"EIGHTHxEIGHTH\"\nTITLE = \"This is the frame\"\nMARGIN = \"10x10\""),
			$ih.fill()
		)
	).set_attributes(
		FGCOLOR => "255 0 0",
		SIZE    => "EIGHTHxEIGHTH",
		TITLE   => "This is the frame",
		MARGIN  => "10x10");  # Sets frame's attributes

	#
	# Creates dialog
	#
	my $dlg = $ih.dialog($frame);
	$dlg.set_attribute("TITLE", "IupFrame");
	$dlg.show(); # Shows dialog in the center of the screen

	$iup.main_loop(); # Initializes IUP main loop
	$iup.close(); # Finishes IUP

	exit();
}
