NAME
====



File::LibMagic - Determine content type and encoding using libmagic

SYNOPSIS
========



    use File::LibMagic;

    my $magic = File::LibMagic.new;

    my %info = $magic.from-filename( 'path/to/file.pm6' );
    if %info<mime-type> ~~ rx{ ^ 'text/' } { ... }

DESCRIPTION
===========



This class provides an API that allows you to get the MIME type and encoding of a file or chunk of in-memory content. It uses the libmagic C library, so you will need to have this installed in order for this class to work.

METHOD
======

File::LibMagic.new(...)

The constructor creates a new magic object. It accepts the following named parameters:

  * `Str @magic-files`

This should be a list of filenames containing magic definitions. This is optional, and if it's not provided then libmagic will use the default magic file on your system (usually something like `/usr/share/file/magic.mgc`).

  * `Bool $follow-symlinks`

By default, libmagic simply returns `inode/symlink` as the MIME type for symlinks. If this parameter is set to `True`, then libmagic will resolve symlinks and given the MIME information for the file that the symlink points.

  * `Bool $uncompress`

By default, when given a compressed file, libmagic gives you a MIME type based on the compression format like `application/gzip`. If this is set to `True` then libmagic will uncompress the file and give you the MIME information for the uncompressed file.

  * `Bool $open-devices`

By default, libmagic gives you the type of the device file, something like `inode/blockdevice`. If this is set to `True`, then libmagic will open the device, read data from it, and give you the MIME information for that data.

  * `Bool $preserve-atime`

If this is set to `True`, libmagic will attempt to preserve the file access time of files it reads.

**Note that because of some internal implementation details of this Perl 6 class, this does not work if you call the `from-handle` method**.

  * `Bool $raw`

If this is set to `True`, then non-printable characters in any data returned by the library are left as-is, rather than being translated into an octal representation (\011).

METHODS
=======



All of the information methods for this class return the same hash structure:

    {
        description => 'A description of this MIME type',
        mime-type   => 'mime/type',
        encoding    => 'UTF-8',
        mime-type-with-encoding => 'mime/type; charset=UTF-8',
    }

All of the methods take any of the flags that can be passed to constructor. These flags only apply for the method call during which they're passed, and override any flags passed to the constructor for that one method call.

METHOD
======

$magic.from-filename( $filename, %flags )

This method takes a filename as a string or [IO::Path](IO::Path) and returns the MIME information for that filename.

METHOD
======

$magic.from-handle( $handle, %flags )

This method takes a handle opened for reading and returns the MIME information for that filename.

Note that this method will actually read data from the file, moving the file pointer. If you want to use the handle later, you should probably could `.seek` on it.

METHOD
======

$magic.from-buffer( $buffer, %flags )

This method accepts a `Str` or `Buf` and returns the MIME information for the data in that object.
