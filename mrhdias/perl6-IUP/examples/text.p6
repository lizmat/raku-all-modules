#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use IUP;

sub MAIN() {
	my $iup = IUP.new();

	my @argv = ("Test");
	$iup.open(@argv);

	my $ih = IUP::Handle.new();

	my $text = $ih.text("");
	$text.set_attribute("SIZE",  "200x");

	my $pwd = $ih.text("");
	$pwd.set_attribute("READONLY", "YES");
	$pwd.set_attribute("SIZE", "200x");

	my $vbox = $ih.vbox($text, $pwd);
	my $dlg = $ih.dialog($vbox);
	$dlg.set_attribute("TITLE", "IupText");
	$dlg.show(IUP_CENTER, IUP_CENTER);

	$iup.main_loop();
	$iup.close();

	exit();
}
