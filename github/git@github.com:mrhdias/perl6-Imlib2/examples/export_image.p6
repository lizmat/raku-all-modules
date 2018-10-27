#!/usr/bin/env perl6

BEGIN { @*INC.push('../lib') };

use Imlib2;

if @*ARGS.elems != 2 {
	say "Error: wrong number of arguments!";
	say "Usage: ./export_image.p6 image format\n";
	say "Format is a string and may be \"jpeg\", \"tiff\", \"png\", etc.";
	say "The exact number of formats supported depends on how you built imlib2.\n";
	say "Ex: ./export_image.p6 images/camelia-logo.jpg png";
	exit();
}

my $im = Imlib2.new();
# load an image
my $loadedimage = $im.load_image(@*ARGS[0]);
unless $loadedimage {
	say "Error: Problem loading file...";
	exit();
}
# Sets the current image Imlib2 will be using with its function calls.
$loadedimage.context_set();

@*ARGS[0] ~~ s/\.\w+$/\.@*ARGS[1]/;

$im.image_set_format(@*ARGS[1]);

if @*ARGS[0].IO ~~ :e {
	my $option = prompt("The " ~ @*ARGS[0] ~ " file already exists - do you want to replace the existing file? [y/n]: ");
	if $option eq "y" {
		unlink(@*ARGS[0])
	} else {
		$im.free_image();
		exit();
	}
}

$im.save_image(@*ARGS[0]);

# Frees the image that is set as the current image in Imlib2's context. 
$im.free_image();

exit();
