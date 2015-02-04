p6-file-directory-tree
======================

Port of File::Path::Tiny to Perl 6 - create and delete directory trees


## SYNOPSIS

	# make a new directory tree
	mktree "foo/bar/baz/quux";
	# delete what you just made
	rmtree "foo";
	# clean up your /tmp -- but don't delete /tmp itself
	empty-directory "/tmp";

	
## DESCRIPTION

This module provides recursive versions of mkdir and rmdir.  This might be useful for things like setting up a repo all at once.

## FUNCTIONS

#### mktree
Makes a directory tree with the given path.  If any elements of the tree do not already exist, this will make new directories.

	sub mktree ($path, $mask = 0o777)

Accepts an optional second argument, the permissions mask.  This is supplied to mkdir, and used for all of the directories it makes; the default is `777` (`a+rwx`).  It takes an integer, but you really should supply something in octal like 0o755 or :8('500').

Returns True if successful.

#### rmtree
This deletes all files under a directory tree with the given path before deleting the directory itself.  It will recursively call unlink and rmdir until everything under the path is deleted.

Returns True if successful, and False if it cannot delete a file.

#### empty-directory
Also deletes all items in a given directory, but leaves the directory itself intact.  After running this, the only thing in the path should be '.' and '..'.

Returns True if successful, and False if it cannot delete a file.

## TODO

* Probably handle errors in the test file better

## SEE ALSO

* [File::Spec](https://github.com/FROGGS/p6-File-Spec)

## AUTHOR

Brent "Labster" Laabs, 2013.

Contact the author at bslaabs@gmail.com or as labster on #perl6.  File [bug reports](https://github.com/labster/p6-IO-Path-More/issues) on github.

Based loosely on code by written Daniel Muey in Perl 5's [File::Path::Tiny](http://search.cpan.org/~dmuey/File-Path-Tiny-0.5/lib/File/Path/Tiny.pod).

## COPYRIGHT

This code is free software, licensed under the same terms as Perl 6; see the LICENSE file for details.

