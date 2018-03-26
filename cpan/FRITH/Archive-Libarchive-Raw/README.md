## Archive::Libarchive::Raw

Archive::Libarchive::Raw - Raw interface to libarchive using NativeCall.

## Build Status

| Operating System  |   Build Status  | CI Provider |
| ----------------- | --------------- | ----------- |
| Linux             | [![Build Status](https://travis-ci.org/frithnanth/perl6-Archive-Libarchive-Raw.svg?branch=master)](https://travis-ci.org/frithnanth/perl6-Archive-Libarchive-Raw)  | Travis CI |

## Example

```Perl6
use v6;

use Archive::Libarchive::Raw;
use Archive::Libarchive::Constants;

sub MAIN(:$file! where { .IO.f // die "file '$file' not found" })
{
  my archive $a = archive_read_new();
  archive_read_support_filter_all($a);
  archive_read_support_format_all($a);
  archive_read_open_filename($a, $file, 10240) == ARCHIVE_OK or die 'Unable to open archive';
  my archive_entry $entry .= new;
  while archive_read_next_header($a, $entry) == ARCHIVE_OK {
    my $name = archive_entry_pathname($entry);
    say $name;
    archive_read_data_skip($a);
  }
  archive_read_free($a) == ARCHIVE_OK or die 'Unable to free internal data structure';
}

```

For more examples see the `example` directory.

## Description

Archive::Libarchive::Raw is a set of simple bindings to libarchive using NativeCall.

As the Libarchive site (http://www.libarchive.org/) states, its implementation is able to:

* Read a variety of formats, including tar, pax, cpio, zip, xar, lha, ar, cab, mtree, rar, and ISO images.
* Write tar, pax, cpio, zip, xar, ar, ISO, mtree, and shar archives.
* Handle automatically archives compressed with gzip, bzip2, lzip, xz, lzma, or compress.

For more details on libarchive see https://github.com/libarchive/libarchive/wiki/ManualPages .

## Prerequisites

This module requires the libarchive library to be installed. Please follow the
instructions below based on your platform:

### Debian Linux

```
sudo apt-get install libarchive13
```

## Installation

```
$ zef install Archive::Libarchive::Raw
```

## Testing

To run the tests:

```
$ prove -e "perl6 -Ilib"
```

## Note

This module relies on a C library which might not be present in one's installation, so it's not a substitute
for a pure Perl6 module.

This is a raw interface to the functions provided by the C library; any program that uses this module might
need to use NativeCall. If you wish to use a higher level interface, please take a look at Archive::Libarchive.

## Author

Fernando Santagata

## Contributions

Many thanks to Jonathan Worthington for the Windows installer code.

## Copyright and license

The Artistic License 2.0
