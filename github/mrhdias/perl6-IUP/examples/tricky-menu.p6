#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use IUP;

sub MAIN() {

	#my @data_Tecgraf = get_data_from_file("images/Tecgraf.txt");
	#my $pixmap = IUP::Pixmap.new();
	#my $imageTecgraf = $pixmap.load(@data_Tecgraf);

	my $iup = IUP.new();

	my @argv = ("Test");
	$iup.open(@argv);

	$iup.image_lib_open();

	my $dlg = menu_test();

	$iup.main_loop();

	$dlg.destroy();

	$iup.close();

	exit();
}

sub get_data_from_file($filename) {
	my @array = ();
	if (my $fh = open $filename, :r) {
		for $fh.lines -> $line {
			@array.push($line.split(/\D+/));
		}
	} else {
		say "Could not open '$filename'";
		exit();
	}
	return @array;
}

sub menu_test() {

	my $ih = IUP::Handle.new();

	#
	# Creates menu create
	#

	my $menu_create = $ih.menu(
		$ih.item("Line", ""),
		$ih.item("Circle", ""),
		$ih.submenu("Triangle",
			$ih.menu(
				$ih.item("Equilateral", "").set_attributes(VALUE => "ON"),
				$ih.item("Isoceles", ""),
				$ih.item("Scalenus", "")
			).set_attributes(RADIO => "YES")
		)
	);

	#
	# File Menu
	#
	my $menu_file = $ih.menu(
		$ih.item("Item with Image \tCtrl+M", ""),
		$ih.item("Toggle using &VALUE", "").set_attributes(VALUE => "ON", KEY => "KcV"),
		$ih.item("Auto &Toggle Text", "").set_attributes(AUTOTOGGLE => "YES", VALUE => "OFF"),
		$ih.item("Auto &Toggle Image", ""),
		$ih.item("Big Image", ""),
		$ih.separator(),
		$ih.item("Exit (Destroy)", ""),
		$ih.item("E&xit (Close)", "")
	);

	#
	# Edit Menu
	#
	my $menu_edit = $ih.menu(
		$ih.item("Active Next", "").set_attributes(IMAGE => "IUP_ArrowRight"),
		$ih.item("Rename Next", ""),
		$ih.item("Set Next Image", ""),
		$ih.item("Item && Acc\tCtrl+A", ""),
		$ih.separator(),
		$ih.submenu("Create", $menu_create)
	);

	#
	# Help Menu
	#

	my $menu_help = $ih.menu(
		$ih.item("Append", ""),
		$ih.item("Insert", ""),
		$ih.item("Remove", ""),
		$ih.separator(),
		$ih.item("Info", "").set_attributes(IMAGE => "IUP_MessageInfo")
	);

	#
	# Creates main menu with file menu
	#

	my $menu = $ih.menu(
		$ih.submenu("Submenu", $menu_file),
		$ih.submenu("Edit", $menu_edit),
		$ih.submenu("Help", $menu_help),
		$ih.item("Item", "")
	);

	my $canvas = $ih.canvas("");
	my $dlg = $ih.dialog($canvas);
	$dlg.set_attribute_handle("MENU", $menu);
	$dlg.set_attributes(
		TITLE => "IupMenu Test",
		SIZE  => "QUARTERxQUARTER");

	#
	# Shows dlg in the center of the screen */
	#
	$dlg.show(IUP_CENTER, IUP_CENTER);

	return $dlg;
	
}
