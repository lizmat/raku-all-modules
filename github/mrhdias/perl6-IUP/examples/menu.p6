#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use IUP;

my $iup = IUP.new();

#$iup.set_language("PORTUGUESE");

my @argv = ("Test Menu");
$iup.open(@argv);

my $ih = IUP::Handle.new();

my $item_open = $ih.item("Open", "");
$item_open.set_attribute("KEY", "O");

my $item_save = $ih.item("Save", "");
$item_save.set_attribute("KEY", "S");

my $item_undo = $ih.item("Undo", "");
$item_undo.set_attribute("KEY", "U");
$item_undo.set_attribute("ACTIVE", "NO");

my $item_exit = $ih.item("Exit", "");
$item_exit.set_attribute("KEY", "x");
$item_exit.set_callback("ACTION", &exit_cb);

my $file_menu = $ih.menu(
	$item_open, 
	$item_save, 
	$ih.separator(),
	$item_undo,
	$item_exit);

my $sub1_menu = $ih.submenu("File", $file_menu);

my $menu = $ih.menu($sub1_menu);

$menu.set_handle("mymenu");

my $canvas = $ih.canvas("");
my $dlg = $ih.dialog($canvas);

$dlg.set_attribute("MENU", "mymenu");

$dlg.set_attribute("TITLE", "IupMenu");
$dlg.set_attribute("SIZE", "200x100");

$dlg.show();

$iup.main_loop();

$iup.close();

exit();


sub exit_cb() returns Int {
	return IUP_CLOSE;
}
