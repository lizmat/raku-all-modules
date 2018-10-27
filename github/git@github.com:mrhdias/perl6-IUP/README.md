perl6-IUP
=========

![IUP Logo](logotype/logo_32x32.png)  
Perl 6 interface to the IUP toolkit for building GUI's.

Description
-----------
Perl 6 interface to the [IUP][2] toolkit. [IUP][2] is a multi-platform toolkit for
building graphical user interfaces. IUP's purpose is to allow a program
source code to be compiled in different systems without any modification.
Its main advantages are:

* it offers a simple API.
* high performance, due to the fact that it uses native interface elements.
* fast learning by the user, due to the simplicity of its API.

Installation
------------
You will need the Linux libraries `libiup` and `libiupimglib` installed
in order to use perl6-IUP (version 3). You can download the library binaries
or sources for your platform from [here][5].

To install with the Panda tool.

	panda update
	panda install IUP

To run a script that uses the IUP library.

	PERL6LIB=$HOME/.perl6/2013.02.1/lib LD_LIBRARY_PATH=$HOME/.perl6/2013.02.1/lib ./hello.p6

Synopsis
--------
WARNING: This module is Work in Progress and is in a early stage, which means:
this interface is not final. This will perhaps change in the future.  
A sample of the code can be seen below.

<p align="center">
<img src="https://raw.github.com/mrhdias/perl6-IUP/master/examples/images/widgets.png" alt="Hello World IUP Application"/>
</p>

	use IUP;

	my @argv = ("Test");

	#
	# initialize iup
	#

	my $iup = IUP.new();

	$iup.image_lib_open();
	$iup.open(@argv);

	#
	# create widgets and set their attributes
	#

	my $btn = $iup.button("&Ok", "");

	$btn.set_callback("ACTION", &exit_callback);

	$btn.set_attribute("IMAGE", "IUP_ActionOk");
	$btn.set_attribute("EXPAND", "YES");
	$btn.set_attribute("TIP", "Exit button");

	my $lbl = $iup.label("Hello, world!");

	my $vb = $iup.vbox($lbl, $btn);
	$vb.set_attribute("MARGIN", "10x10");
	$vb.set_attribute("GAP", "10");
	$vb.set_attribute("ALIGNMENT", "ACENTER");

	my $dlg = $iup.dialog($vb);
	$dlg.set_attribute("TITLE", "Hello");

	#
	# Map widgets and show dialog
	#

	$dlg.show();

	#
	# Wait for user interaction
	#

	$iup.main_loop();

	#
	# Clean up
	#

	$dlg.destroy();
	$iup.close();

	exit();

	sub exit_callback() returns Int {
		return IUP_CLOSE;
	}

Author
------
Henrique Dias <mrhdias@gmail.com>

See Also
--------
* [IUP Perl6 Module Documentation][1]
* [IUP Site][2]  
* [IUP Source Repository][3]
* [C examples from IUP source repository][4]

License
-------

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

[1]: lib/IUP.pod "IUP Perl6 Module Documentation"
[2]: http://www.tecgraf.puc-rio.br/iup/ "IUP - Portable User Interface"
[3]: http://iup.cvs.sourceforge.net/viewvc/iup/iup/ "IUP Source Repository"
[4]: http://iup.cvs.sourceforge.net/viewvc/iup/iup/test/ "C examples from IUP source repository"
[5]: http://sourceforge.net/projects/iup/files/3.7/ "IUP Downloads"
