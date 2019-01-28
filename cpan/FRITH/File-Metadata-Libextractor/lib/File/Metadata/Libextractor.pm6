use v6.c;

unit class File::Metadata::Libextractor:ver<0.0.2>:auth<cpan:FRITH>;

use NativeCall;
use File::Metadata::Libextractor::Raw;
use File::Metadata::Libextractor::Constants;

has $.plugins;

my %metatypemap = EXTRACTOR_MetaType.enums.antipairs;
my %formatmap   = EXTRACTOR_MetaFormat.enums.antipairs;

submethod BUILD(Bool :$in-process?)
{
  $!plugins = EXTRACTOR_plugin_add_defaults($in-process ??
                                              EXTRACTOR_OPTION_IN_PROCESS !!
                                              EXTRACTOR_OPTION_DEFAULT_POLICY);
}

method extract($file where .IO.f // fail "file '$file' not found" --> List)
{
  my @info;
  EXTRACTOR_extract(
    $!plugins,
    $file,
    Pointer[void],
    0,
    -> $, *@args {
      @info.push:
        (<plugin-name plugin-type plugin-format mime-type data-type>
          Z=>
          (@args[0], %metatypemap{@args[1]}, %formatmap{@args[2]}, @args[3], @args[4])).hash;
      0;
    },
    Pointer[void]
  );
  @info;
}

submethod DESTROY
{
  EXTRACTOR_plugin_remove_all($!plugins);
}

=begin pod

=head1 NAME

File::Metadata::Libextractor - Use libextractor to read file metadata

=head1 SYNOPSIS

=begin code
use File::Metadata::Libextractor;

#| This program extracts all the information about a file
sub MAIN($file! where { .IO.f // die "file '$file' not found" })
{
  my File::Metadata::Libextractor $e .= new;
  my @info = $e.extract($file);
  for @info -> %record {
    for %record.kv -> $k, $v {
      say "$k: $v"
    }
    say '-' x 50;
  }
}
=end code

=head1 DESCRIPTION

File::Metadata::Libextractor provides an OO interface to libextractor in order to query files' metadata.

As the Libextractor site (L<https://www.gnu.org/software/libextractor>) states, it is able to read information
in the following file types:

=item HTML
=item MAN
=item PS
=item DVI
=item OLE2 (DOC, XLS, PPT)
=item OpenOffice (sxw)
=item StarOffice (sdw)
=item FLAC
=item MP3 (ID3v1 and ID3v2)
=item OGG
=item WAV
=item S3M (Scream Tracker 3)
=item XM (eXtended Module)
=item IT (Impulse Tracker)
=item NSF(E) (NES music)
=item SID (C64 music)
=item EXIV2
=item JPEG
=item GIF
=item PNG
=item TIFF
=item DEB
=item RPM
=item TAR(.GZ)
=item LZH
=item LHA
=item RAR
=item ZIP
=item CAB
=item 7-ZIP
=item AR
=item MTREE
=item PAX
=item CPIO
=item ISO9660
=item SHAR
=item RAW
=item XAR FLV
=item REAL
=item RIFF (AVI)
=item MPEG
=item QT
=item ASF

Also, various additional MIME types are detected.

=head2 new(Bool :$in-process?)

Creates a B<File::Metadata::Libextractor> object.

libextractor interfaces to several libraries in order to extract the metadata. To work safely it starts sub-processes
to perform the actual extraction work.

This might cause problems in a concurrent envirnment with locks.
A possible solution is to run the extraction process inside the program's own process. It's less secure, but it may
avoid locking problems.

The optional argument B<$in-process> allows the execution of the extraction job in the parent's process.

=head2 extract($file where .IO.f // fail "file '$file' not found" --> List)

Reads all the possible information from an existing file, or fails if the file doesn't exist.
The output B<List> is actually a List of Hashes. Each hash has the following keys:

=item mime-type      The file's mime-type
=item plugin-name    The name of the plugin the library used to find out the information
=item plugin-type    The plugin subtype used for the operation
=item plugin-format  The format of the plugin's output
=item data-type      The value returned by the plugin subtype

The possible values for B<plugin-format> are:

=item EXTRACTOR_METAFORMAT_UNKNOWN
=item EXTRACTOR_METAFORMAT_UTF8
=item EXTRACTOR_METAFORMAT_BINARY
=item EXTRACTOR_METAFORMAT_C_STRING

The possible values for the B<plugin-type> field are listed in File::Metadata::Libextractor::Constants,
in the EXTRACTOR_MetaType enum (231 values as for v3.1.6).

=head1 Prerequisites

This module requires the libextractor library to be installed. It has been successfully tested on the
following Linux distributions:

=item Debian 9
=item Debian sid
=item Ubuntu 16.04
=item Ubuntu 18.04

It doesn't work with the version of the library that comes with Ubuntu 14.04.

=begin code
sudo apt-get install libextractor3
=end code

This module looks for a library called libextractor.so.3 .

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install File::Metadata::Libextractor
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "perl6 -Ilib"
=end code

=head1 AUTHOR

Fernando Santagata <nando.santagata@gmail.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2018 Fernando Santagata

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
