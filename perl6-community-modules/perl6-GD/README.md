perl6-GD
========

![GD Logo](logotype/logo_32x32.png)  
Perl 6 interface to the Gd graphics library.

Description
-----------
Perl6 interface to Thomas Boutell's [gd graphics library][2]. GD allows you to create color drawings using a large number of graphics primitives, and emit the drawings in multiple formats.
You will need the Linux `gd-libgd` library or OS X `gd2` port installed in order to use perl6-GD (preferably a recent version).

Synopsis
--------
WARNING: This module is Work in Progress, which means: this interface is not final. This will perhaps change in the future.  
A sample of the code can be seen below.

	use GD;

	my $image = GD::Image.new(200, 200);
	exit() unless $image;

	my $black = $image.colorAllocate(
		red   => 0,
		green => 0,
		blue  => 0);

	my $white = $image.colorAllocate(
		red   => 255,
		green => 255,
		blue  => 255);

	my $red = $image.colorAllocate("#ff0000");
	my $green = $image.colorAllocate("#00ff00");
	my $blue = $image.colorAllocate(0x0000ff);

	$image.rectangle(
		location => (10, 10),
		size     => (100, 100),
		fill     => True,
		color    => $white);

	$image.line(
		start => (10, 10),
		end   => (190, 190),
		color => $black);

	my $png_fh = $image.open("test.png", "wb");

	$image.output($png_fh, GD_PNG);

	$png_fh.close;

	$image.destroy();

	exit();

Author
------
Henrique Dias <mrhdias@gmail.com>

See Also
--------
* [GD Perl6 Module Documentation][1]  
* [GD Source Repository][2]
* [C examples from GD source repository][3]

License
-------

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

[1]: lib/GD.pod "GD Perl6 Module Documentation"
[2]: https://bitbucket.org/pierrejoye/gd-libgd "GD Source Repository"
[3]: https://bitbucket.org/pierrejoye/gd-libgd/src/2b8f5d19e0c9/examples "C examples from GD source repository"
