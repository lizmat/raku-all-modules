p6-IO-Path-More
===============

IO::Path::More - Extends IO::Path to make it more like p5's Path::Class

## SYNOPSIS

	#Create a path object
	$path1 = path 'foo/bar/baz.txt';
	$path2 = IO::Path::More.new('/usr/local/bin/perl6');

	#We can do anything that IO::Path does
	say "file exists" if $path2.e;
	my @lines = $path1.open.lines;

	# But wait, there's More!
        $path3 = path "/new/directory/tree";
        $path3.mkpath;              # makes /new, /new/directory, and /new/directory/tree
	$path3.=append("erf", 'quux.txt');   # "/new/directory/tree/erf/quux.txt"
        $path3.touch;               # makes an empty "quux.txt" file
	path("/new").rmtree         # removes everything under "/new"

	# Not quite working yet: Foreign paths
	# It should work correctly if you run Windows, though.
	$WindowsPath = IO::Path::More.new('C:\\bar\\baz\\\\', OS => 'MSWin32');
	#                                     ^ don't forget to escape your backslashes
	say $WindowsPath;                       # "C:\bar\baz"
	say $WindowsPath.volume;                # "C:"

	
## DESCRIPTION

IO::Path::More is intended to be a cross-platform replacement for the built-in IO::Path.  Internally, we use File::Spec to deal with all of the issues on differing paths on different operating systems, so you don't have to.

Currently, only Win32 and Unix-type systems are finished (including Mac OS X) in P6 File::Spec, but support should get better as File::Spec gains more OSes.

## INTERFACE

There are two ways to create an IO::Path::More object.  Either though the object interface, or via the path function.

	IO::Path::More.new( $mypath );
	path $mypath;

While you can create a path object with named arguments, you probably shouldn't, unless you don't want path cleanup to happen.

Note that the methods do not actually transform the object, but rather return a new IO::Path::More object.  Therefore, if you want to change the path, use a mutating method, like `$path.=absolute`.

## METHODS
This module provides a class based interface to all sorts of filesystem related functions on paths:

#### append( *@parts )
Concatenates anything passed onto the end of the path, and returns the result in a new object.  For example, `path("/foo").append(<bar baz/zig>)` will return a path of `/foo/bar/baz/zig`.

#### find(:$name, :$type, Bool :$recursive = True)
Calls File::Find with the given options, which are explained in the File::Find documentation.  Note that File::Find is not 100% cross-platform yet, so beware on systems where '/' is not a path separator.

#### remove
Deletes the current path.  Calls unlink if the path is a file, or calls rmdir if the path is a directory.  Fails if there are files in the directory, or if you do not have permission to delete the path.

To remove an entire directory with its contents, see `rmtree`.

#### rmtree
Deletes the path, and all of the contents of that directory.  Equivalent
to `rm -rf` on unix boxen.  Fails as remove above.

#### mkpath

Makes a directory path out of new directories, as necessary.  Equivalent
to `mkdir -p` on the a linux machine.

### IO methods
Methods included in IO::Path (notably .open, .close, and .contents) are available here.  See [S32/IO](http://perlcabal.org/syn/S32/IO.html) for details.

### NYI Methods
Not yet implemented due to missing features in Rakudo:
* touch   (needs utime)
* resolve (needs readlink)
* stat    (needs stat)

### Filetest methods

#### .e, .d, .l, etc...
Builtin methods are reproduced here.  Because we inherit from IO::Path, IO::Path::More does IO::Filetestable.  See [S32/IO](http://perlcabal.org/syn/S32/IO.html) for details.

#### inode
Returns the inode number of the current path as an Int.  If you're not on a POSIX system, returns False.  Inode numbers uniquely identify files on a given device, and all hard links point to the same inode.

#### device
Returns the device number of the current path from a stat call.  This is not the same as `.volume`, though both identify the disk/drive/partition.

## TODO

* NYI above
* Foreign paths

## SEE ALSO

* [File::Spec](https://github.com/FROGGS/p6-File-Spec)
* [File::Tools](https://github.com/tadzik/perl6-File-Tools/) - the source of File::Find

## AUTHOR

Brent "Labster" Laabs, 2013.

Contact the author at bslaabs@gmail.com or as labster on #perl6.  File [bug reports](https://github.com/labster/p6-IO-Path-More/issues) on github.

## COPYRIGHT

This code is free software, licensed under the same terms as Perl 6; see the LICENSE file for details.

Some methods are based on code originally written by Ken Williams for the Perl 5 module [Path::Class](http://search.cpan.org/~kwilliams/Path-Class/README.pod).
