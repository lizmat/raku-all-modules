## Archive::Libarchive

Archive::Libarchive - OO interface to libarchive.

## Build Status

| Operating System  |   Build Status  | CI Provider |
| ----------------- | --------------- | ----------- |
| Linux             | [![Build Status](https://travis-ci.org/frithnanth/perl6-Archive-Libarchive.svg?branch=master)](https://travis-ci.org/frithnanth/perl6-Archive-Libarchive)  | Travis CI |

## Example

```Perl6
use v6;

use Archive::Libarchive;
use Archive::Libarchive::Constants;

sub MAIN(:$file! where { .IO.f // die "file '$file' not found" })
{
  my Archive::Libarchive $a .= new:
      operation => LibarchiveExtract,
      file => $file,
      flags => ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS;
  try {
    $a.extract: sub (Archive::Libarchive::Entry $e --> Bool) { $e.pathname eq 'test2' };
    CATCH {
      say "Can't extract files: $_";
    }
  }
  $a.close;
}
```

For more examples see the `example` directory.

## Description

Archive::Libarchive provides a procedural and a OO interface to libarchive using Archive::Libarchive::Raw.

As the Libarchive site (http://www.libarchive.org/) states, its implementation is able to:

* Read a variety of formats, including tar, pax, cpio, zip, xar, lha, ar, cab, mtree, rar, and ISO images.
* Write tar, pax, cpio, zip, xar, ar, ISO, mtree, and shar archives.
* Handle automatically archives compressed with gzip, bzip2, lzip, xz, lzma, or compress.

## Documentation

#### new(LibarchiveOp :$operation!, Any :$file?, Int :$flags?, Str :$format?, :@filters?)

Creates an Archive::Libarchive object. It takes one **mandatory** argument:
`operation`, what kind of operation will be performed.

The list of possible operations is provided by the `LibarchiveOp` enum:

* `LibarchiveRead`: open the archive to list its content.
* `LibarchiveWrite`: create a new archive. The file must not be already present.
* `LibarchiveOverwrite`: create a new archive. The file will be overwritten if present.
* `LibarchiveExtract`: extract the archive content.

When extracting one can specify some options to be applied to the newly created files. The default options are:

`ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS`

Those constants are defined in Archive::Libarchive::Constants, part of the Archive::Libarchive::Raw
distribution.
More details about those operation modes can be found on the libarchive site: http://www.libarchive.org/

If the optional argument `$file` is provided, then it will be opened; if not provided
during the initialization, the program must call the `open` method later.

If the optional `$format` argument is provided, then the object will select that specific format
while dealing with the archive.

List of possible read formats:

* 7zip
* ar
* cab
* cpio
* gnutar
* iso9660
* lha
* mtree
* rar
* raw
* tar
* warc
* xar
* zip

List of possible write formats:

* 7zip
* ar
* cpio
* gnutar
* iso9660
* mtree
* pax
* raw
* shar
* ustar
* v7tar
* warc
* xar
* zip

If the optional `@filters` parameter is provided, then the object will add those filter to the archive.
Multiple filters can be specified, so a program can manage a file.tar.gz.uu for example.
The order of the filters is significant, in order to correctly deal with such files as file.tar.uu.gz and
file.tar.gz.uu .

List of possible read filters:

* bzip2
* compress
* gzip
* grzip
* lrzip
* lz4
* lzip
* lzma
* lzop
* none
* rpm
* uu
* xz

List of possible write filters:

* b64encode
* bzip2
* compress
* grzip
* gzip
* lrzip
* lz4
* lzip
* lzma
* lzop
* none
* uuencode
* xz

##### Note

Recent versions of libarchive implement an automatic way to determine the best mix of format and filters.
If one's using a pretty recent libarchive, both $format and @filters may be omitted: the `new` method will
determine automatically the right combination of parameters.
Older versions though don't have that capability and the programmer has to define explicitly both parameters.

#### open(Str $filename!, Int :$size?, :$format?, :@filters?)
#### open(Buf $data!)

Opens an archive; the first form is used on files, while the second one is used to open an archive that
resides in memory.

The first argument is always mandatory, while the other ones might been omitted.

$size is the size of the internal buffer and defaults to 10240 bytes.

#### close

Closes the internal archive object, frees the memory and cleans up.

#### extract-opts(Int $flags?)

Sets the options for the files created when extracting files from an archive.
The default options are:

`ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS`

#### next-header(Archive::Libarchive::Entry:D $e! --> Bool)

When reading an archive this method fills the Entry object and returns True till it reaches the end of the archive.

The Entry object is pubblicly defined inside the Archive::Libarchive module. It's initialized this way:

`my Archive::Libarchive::Entry $e .= new;`

So a complete archive lister can be implemented in few lines:

```Perl6
use v6;
use Archive::Libarchive;

sub MAIN(Str :$file! where { .IO.f // die "file '$file' not found" })
{
  my Archive::Libarchive $a .= new: operation => LibarchiveRead, file => $file;
  my Archive::Libarchive::Entry $e .= new;
  while $a.next-header($e) {
    $e.pathname.say;
    $a.data-skip;
  }
  $a.close;
}

```

#### data-skip(--> Int)

When reading an archive this method skips file data to jump to the next header.
It returns `ARCHIVE_OK` or `ARCHIVE_EOF` (defined in Archive::Libarchive::Constants)

#### write-header(Str $file, Int :$size?, Int :$filetype?, Int :$perm?, Int :$atime?, Int :$mtime?, Int :$ctime?, Int :$birthtime?, Int :$uid?, Int :$gid?, Str :$uname?, Str :$gname?  --> Bool)

When creating an archive this method writes the header entry for the file being inserted into the archive.
The only mandatory argument is the file name, every other argument has a reasonable default.
More details can be found on the libarchive site.

Each optional argument is available as a method of the Archive::Libarchive::Entry object and it can be set when needed.

#### write-data(Str $path --> Bool)

When creating an archive this method writes the data for the file being inserted into the archive.

#### extract(Str $destpath? --> Bool)
#### extract(&callback:(Archive::Libarchive::Entry $e --> Bool)!, Str $destpath? --> Bool)

When extracting files from an archive this method does all the dirty work.
If used in the first form it extracts all the files.
The second form takes a callback function, which receives a Archive::Libarchive::Entry object.

For example, this will extract only the file whose name is `test2`:

`$a.extract: sub (Archive::Libarchive::Entry $e --> Bool) { $e.pathname eq 'test2' };`

In both cases one can specify the directory into which the files will be extracted.

#### lib-version

Returns a hash with the version number of libarchive and of each library used internally.

### Errors

When the underlying library returns an error condition, the methods will return a Failure object, which can
be trapped and the exception can be analyzed and acted upon.

The exception object has two fields: $errno and $error, and return a message stating the error number and
the associated message as delivered by libarchive.

## Prerequisites
This module requires Archive::Libarchive::Raw Perl6 module and the libarchive library 
to be installed. Please follow the instructions below based on your platform:

### Debian Linux

```
sudo apt-get install libarchive13
```

The module looks for a library called libarchive.so, or whatever it finds in
the environment variable `PERL6_LIBARCHIVE_LIB` (provided that the library one
chooses uses the same API).

## Installation

To install it using Panda (a module management tool):

```
$ panda update
$ panda install Archive::Libarchive
```
To install it using zef (a module management tool):

```
$ zef update
$ zef install Archive::Libarchive
```

## Testing

To run the tests:

```
$ prove -e "perl6 -Ilib"
```

or

```
$ prove6
```

## Note

Archive::Libarchive::Raw and in turn this module rely on a C library which might not be present in one's
installation, so it's not a substitute for a pure Perl6 module.

This is a OO interface to the functions provided by the C library, accessible through the Archive::Libarchive::Raw
module.

## Author

Fernando Santagata

## Copyright and license

The Artistic License 2.0
