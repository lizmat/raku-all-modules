perl6-Imlib2
============

![Imlib2 Logo](logotype/logo_32x32.png)  
Perl 6 interface to the Imlib2 image library.

Description
-----------
Perl6 binding for [Imlib2][2], a featureful and efficient image manipulation library, which produces high quality, anti-aliased output.  

Installation
------------
Note that a recent version of [Imlib2][3] library must be installed before installing this module.

To install with the Panda tool.

	panda update
	panda install Imlib2

To run a sample script that uses the Imlib2 library.

	git clone git://github.com/mrhdias/perl6-Imlib2.git
	cd perl6-Imlib2/examples
	PERL6LIB=$HOME/.perl6/2013.02.1/lib LD_LIBRARY_PATH=$HOME/.perl6/2013.02.1/lib ./imlib2.p6

Synopsis
--------
WARNING: This module is Work in Progress, which means: this interface is not final. This will perhaps change in the future.  
A sample of the code can be seen below.

	use Imlib2;

	my $im = Imlib2.new();
	# Create a new raw image.
	my $rawimage = $im.create_image(200, 200);
	exit() unless $rawimage;

	# Sets the current image Imlib2 will be using with its function calls.
	$rawimage.context_set();
 
	# Sets the color with which text, lines and rectangles are drawn when
	# being rendered onto an image.
	$im.context_set_color(
		red   => 255,
		green => 127,
		blue  => 0,
		alpha => 255);
 
	$im.image_draw_rectangle(
		location => (0, 0),
		size     => (200, 200),
		fill     => True);

	$im.image_set_format("png");
	unlink("images/test_imlib2.png") if "images/test_imlib2.png".IO ~~ :e;
	$im.save_image("images/test_imlib2.png");

	# Frees the image that is set as the current image in Imlib2's context. 
	$im.free_image();

	exit();

Author
------
Henrique Dias <mrhdias@gmail.com>

See Also
--------
* [Imlib2 Perl6 Module Documentation][1]  
* [Imlib2 Library Documentation][2]
* [Imlib2 Source Repository][3]

License
-------

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

[1]: lib/Imlib2.pod "Imlib2 Perl6 Module Documentation"
[2]: http://docs.enlightenment.org/api/imlib2/html/ "Imlib2 Library Documentation"
[3]: http://sourceforge.net/projects/enlightenment/files/imlib2-src/
