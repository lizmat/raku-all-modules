p6-File-Spec-Case
=================

Check if your filesystem is case sensitive or case tolerant (insensitive)

## SYNOPSIS

	use File::Spec::Case;
	say File::Spec::Case.tolerant;  #tests case tolerance in $*CWD
	my $folder = "/path/to/folder";
	say "case sensitive"
	    if File::Spec::Case.sensitive($folder, :no-write);
	say "$folder is case-{ File::Spec::insensitive($folder) ?? 'in' !! ''}sensitive";
	

## DESCRIPTION

Given a directory, this module attempts to determine whether that particular part of the filesystem is case sensitive or insensitive.  In order to be platform independendent, this module interacts with the filesystem to attempt to determine case, because nowadays it's entirely possible to support multiple case filesystems on Windows, Linux, and Mac OS X.

This module splits little-used functionality off from [File::Spec](https://github.com/FROGGS/p6-File-Spec), and has moved to its own module if you need it.  Unlike in  Perl 5, it now applies only to a specific directory -- with symlinks and multiple partitions, you can't assume anything beyond that.

## METHODS

### tolerant

	method tolerant (Str:D $path = $*CWD, :$no_write = False )

Method `tolerant` now requires a path (as compared to Perl 5 File::Spec->case_tolerant), below which it tests for case sensitivity.  The default path it tests is $*CWD.  A :no-write parameter may be passed if you want to disable writing of test files (which is tried last).

	File::Spec::Case.tolerant('foo/bar');
	File::Spec::Case.tolerant('/etc', :no-write);

It will find case (in)sensitivity if any of the following are true, in increasing order of desperation:

* The $path passed contains \<alpha\> and no symbolic links.
* The $path contains \<alpha\> after the last symlink.
* Any folders in the path (under the last symlink, if applicable) contain a file matching \<alpha\>.
* Any folders in the path (under the last symlink, if applicable) are writable.

Otherwise, it returns the platform default.

### insensitive
A synonym for `.tolerant`.

### sensitive
An antonym for `.tolerant` -- that is, it returns `not tolerant`.  Takes the same arguments as tolerant.

### default-case-tolerant
The method of last resort for `.tolerant`, this returns the default value for whether the platform is insensitive to case.  If passed an OS string, it will look for the default on that OS instead.

The default is essentially what you'll get if you do a default install of your operating system.

### always-case-tolerant
Returns True if your OS is on the list of þe olde Turing machine systems of operating with case tolerance, False otherwise.  If you pass another OS string, it will check that instead of your own OS.

This is used as a shortcut in `.tolerant` for machines which never support case-sensitive file naming.

## SEE ALSO

* [File::Spec](https://github.com/FROGGS/p6-File-Spec)

## AUTHOR

Brent "Labster" Laabs, 2013.

Contact the author at bslaabs@gmail.com or as labster on #perl6.  File [bug reports](https://github.com/labster/p6-IO-File-Spec-Case/issues) on github.

## COPYRIGHT

This code is free software, licensed under the same terms as Perl 6; see the LICENSE file for details.
