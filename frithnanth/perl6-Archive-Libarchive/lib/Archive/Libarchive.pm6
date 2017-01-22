use v6;
unit class Archive::Libarchive:ver<0.0.7>;

use NativeCall;
use Archive::Libarchive::Raw;
use Archive::Libarchive::Constants;

enum LibarchiveOp  is export <LibarchiveRead LibarchiveWrite LibarchiveOverwrite LibarchiveExtract>;

constant ARCHIVE_CREATE         is export = 10;
constant ARCHIVE_READ_FORMAT    is export = 20;
constant ARCHIVE_READ_FILTER    is export = 30;
constant ARCHIVE_WRITE_FORMAT   is export = 40;
constant ARCHIVE_WRITE_FILTER   is export = 50;
constant ARCHIVE_FILE_NOT_FOUND is export = 60;
constant ARCHIVE_FILE_FOUND     is export = 70;
constant ARCHIVE_OPEN           is export = 80;
constant ENTRY_ERROR            is export = 90;

class X::Libarchive is Exception
{
  has Int $.errno;
  has Str $.error;

  method message { "Error {$!errno}: $!error"; }
}

class Entry
{
  trusts Archive::Libarchive;
  has archive_entry $.entry;
  has Bool $!safe;

  submethod BUILD(Str :$path?, Int :$size?, Int :$filetype?, Int :$perm?, Int :$operation?)
  {
    if $operation ~~ LibarchiveWrite|LibarchiveOverwrite {
      $!entry = archive_entry_new;
      $!safe = True;
      if $path.defined {
        self.pathname: $path;
        self.size: $size // $path.IO.s;
        self.filetype: $filetype // AE_IFREG;
        self.perm: $perm // 0o644;
      }
    } else {
      $!entry = archive_entry.new;
      $!safe = False;
    }
  }

  method !safe
  {
    $!safe = True;
  }

  multi method pathname(Str $path)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_pathname $!entry, $path;
  }

  multi method pathname(--> Str)
  {
    archive_entry_pathname $!entry;
  }

  multi method size(Int $size)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_size $!entry, $size;
  }

  multi method size(--> int64)
  {
    archive_entry_size $!entry;
  }

  method filetype(Int $type)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_filetype $!entry, $type;
  }

  method perm(Int $perm)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_perm $!entry, $perm;
  }

  multi method atime(Int $atime)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_atime $!entry, $atime, 0;
  }

  multi method atime()
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_unset_atime $!entry;
  }

  multi method ctime(Int $ctime)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_ctime $!entry, $ctime, 0;
  }

  multi method ctime()
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_unset_ctime $!entry;
  }

  multi method mtime(Int $mtime)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_mtime $!entry, $mtime, 0;
  }

  multi method mtime()
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_unset_mtime $!entry;
  }

  multi method birthtime(Int $birthtime)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_birthtime $!entry, $birthtime, 0;
  }

  multi method birthtime()
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_unset_birthtime $!entry;
  }

  method uid(Int $uid)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_uid $!entry, $uid;
  }

  method gid(Int $gid)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_gid $!entry, $gid;
  }

  method uname(Str $uname)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_uname $!entry, $uname;
  }

  method gname(Str $gname)
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_set_gname $!entry, $gname;
  }

  method free()
  {
    if ! $!safe {
      fail X::Libarchive.new: errno => ENTRY_ERROR, error => 'Read-only entry';
    }
    archive_entry_free $!entry;
  }
}

has archive $.archive;
has archive $!ext;
has Int $.operation;

submethod BUILD(LibarchiveOp :$operation!, Any :$file?, Int :$flags?, Str :$format?, :@filters? where .all ~~ Str)
{
  $!operation = $operation;
  if $!operation ~~ LibarchiveRead|LibarchiveExtract {
    $!archive = archive_read_new;
    if ! $!archive.defined {
      fail X::Libarchive.new: errno => ARCHIVE_CREATE, error => 'Error creating libarchive C struct';
    }
    my $res = archive_read_support_format_all $!archive;
    if $res != ARCHIVE_OK {
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive);
    }
    $res = archive_read_support_filter_all $!archive;
    if $res != ARCHIVE_OK {
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive);
    }
  } elsif $!operation ~~ LibarchiveWrite|LibarchiveOverwrite {
    $!archive = archive_write_new;
    if ! $!archive.defined {
      fail X::Libarchive.new: errno => ARCHIVE_CREATE, error => 'Error creating libarchive C struct';
    }
  } else {
    fail X::Libarchive.new: errno => ARCHIVE_CREATE, error => 'Wrong operation mode';
  }
  if $!operation == LibarchiveExtract {
    $!ext = archive_write_disk_new;
    if ! $!ext.defined {
      fail X::Libarchive.new: errno => ARCHIVE_CREATE, error => 'Error creating libarchive C struct';
    }
    if $flags.defined {
      self.extract-opts: $flags;
    }
  }
  if $file.defined {
    self.open: $file, format => $format, filters => @filters;
  }
}

multi method open(Str $filename! where ! .IO.f, Int :$size? = 10240, Str :$format?, :@filters? where .all ~~ Str)
{
  if $!operation ~~ LibarchiveWrite|LibarchiveOverwrite {
    my $res;
    if defined ($format, @filters[0]).all {
      $res = archive_write_set_format_by_name $!archive, $format;
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
      for @filters -> $filter {
        next if $filter eq 'none';
        $res = archive_write_add_filter_by_name $!archive, $filter;
        fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
      }
    } elsif defined ($format, @filters[0]).any {
      fail X::Libarchive.new: errno => ARCHIVE_OPEN, error => 'Both format and filter must be defined.';
    } else {
      $res = archive_write_set_format_filter_by_ext $!archive, $filename;
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
    }
    $res = archive_write_open_filename $!archive, $filename;
    fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
  } elsif $!operation == LibarchiveRead|LibarchiveExtract {
    fail X::Libarchive.new: errno => ARCHIVE_FILE_NOT_FOUND, error => 'File not found';
  }
}

multi method open(Str $filename! where .IO.f, Int :$size? = 10240, Str :$format?, :@filters? where .all ~~ Str)
{
  if $!operation ~~ LibarchiveRead|LibarchiveExtract {
    my $res = archive_read_open_filename $!archive, $filename, $size;
    if $res != ARCHIVE_OK {
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive);
    }
  } elsif $!operation == LibarchiveWrite {
    fail X::Libarchive.new: errno => ARCHIVE_FILE_FOUND, error => 'File already present';
  } elsif $!operation == LibarchiveOverwrite {
    my $res;
    if defined ($format, @filters[0]).all {
      $res = archive_write_set_format_by_name $!archive, $format;
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
      for @filters -> $filter {
        $res = archive_write_add_filter_by_name $!archive, $filter;
        fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
      }
    } elsif defined ($format, @filters[0]).any {
      fail X::Libarchive.new: errno => ARCHIVE_OPEN, error => 'Both format and filter must be defined.';
    } else {
      $res = archive_write_set_format_filter_by_ext $!archive, $filename;
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
    }
    $res = archive_write_open_filename $!archive, $filename;
    fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
  }
}

multi method open(Buf $data!)
{
  my $res = archive_read_open_memory $!archive, $data, $data.bytes;
  if $res != ARCHIVE_OK {
    fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive);
  }
}

method close
{
  if $!archive.defined {
    if $!operation == LibarchiveRead|LibarchiveExtract {
      my $res = archive_read_close $!archive;
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
      $res = archive_read_free $!archive;
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
      if $!operation == LibarchiveExtract {
        my $res = archive_write_close $!ext;
        fail X::Libarchive.new: errno => $res, error => archive_error_string($!ext) unless $res == ARCHIVE_OK;
        $res = archive_write_free $!ext;
        fail X::Libarchive.new: errno => $res, error => archive_error_string($!ext) unless $res == ARCHIVE_OK;
      }
    } elsif $!operation ~~ LibarchiveWrite|LibarchiveOverwrite {
      my $res = archive_write_close $!archive;
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
      $res = archive_write_free  $!archive;
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive) unless $res == ARCHIVE_OK;
    }
  }
}

method extract-opts(Int $flags? =
  ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS)
{
  if $!operation == LibarchiveExtract {
    my $res = archive_write_disk_set_options $!ext, $flags;
    fail X::Libarchive.new: errno => $res, error => archive_error_string($!ext) unless $res == ARCHIVE_OK;
    $res = archive_write_disk_set_standard_lookup $!ext;
    fail X::Libarchive.new: errno => $res, error => archive_error_string($!ext) unless $res == ARCHIVE_OK;
  }
}

method next-header(Archive::Libarchive::Entry:D $e! --> Bool)
{
  my $res = archive_read_next_header $!archive, $e.entry;
  if $res != (ARCHIVE_OK, ARCHIVE_EOF).any {
    fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive);
  }
  $e!Archive::Libarchive::Entry::safe;
  return $res == ARCHIVE_OK ?? True !! False;
}

method write-header(Str $file,
                    Int :$size? = $file.IO.s,
                    Int :$filetype? = AE_IFREG,
                    Int :$perm? = 0o644,
                    Int :$atime? = $file.IO.accessed.Int,
                    Int :$mtime? = $file.IO.modified.Int,
                    Int :$ctime? = $file.IO.changed.Int,
                    Int :$birthtime?,
                    Int :$uid?,
                    Int :$gid?,
                    Str :$uname?,
                    Str :$gname?
                    --> Bool)
{
  my $e = Archive::Libarchive::Entry.new(:$!operation, :$file);
  $e.pathname($file);
  $e.size($size);
  $e.filetype($filetype);
  $e.perm($perm);
  $e.atime($atime);
  $e.ctime($ctime);
  $e.mtime($mtime);
  $e.birthtime($birthtime) if $birthtime.defined;
  $e.uid($uid) if $uid.defined;
  $e.gid($gid) if $gid.defined;
  $e.uname($uname) if $uname.defined;
  $e.gname($gname) if $gname.defined;
  my $res = archive_write_header $!archive, $e.entry;
  if $res != ARCHIVE_OK {
    fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive);
  }
  $e.free;
  return True;
}

method write-data(Str $path --> Bool)
{
  my $fh = open $path, :r;
  my $res;
  while my $buffer = $fh.read(8192) {
    $res = archive_write_data($!archive, $buffer, $buffer.bytes);
    if $res < 0 {
      fail X::Libarchive.new: errno => - $res, error => archive_error_string($!archive);
    }
  }
  $fh.close;
  return True;
}

method data-skip(--> Int)
{
  my $res = archive_read_data_skip $!archive;
  if $res != (ARCHIVE_OK, ARCHIVE_EOF).any {
    fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive);
  }
  return $res;
}

method !copy-data(--> Bool)
{
  my $res;
  my $buff = Pointer[void].new;
  my int64 $size;
  my int64 $offset;
  loop {
    $res = archive_read_data_block $!archive, $buff, $size, $offset;
    return True if $res == ARCHIVE_EOF;
    if $res > ARCHIVE_OK {
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!archive);
    }
    $res = archive_write_data_block $!ext, $buff, $size, $offset;
    if $res > ARCHIVE_OK {
      fail X::Libarchive.new: errno => $res, error => archive_error_string($!ext);
    }
  }
  return True;
}

multi method extract(&callback:(Archive::Libarchive::Entry $e --> Bool)!, Str $destpath? --> Bool)
{
  my $e = Archive::Libarchive::Entry.new;
  my Bool $res = False;
  while (my $rres = archive_read_next_header $!archive, $e.entry) == ARCHIVE_OK {
    last if $rres == ARCHIVE_EOF;
    if $rres != ARCHIVE_OK {
      fail X::Libarchive.new: errno => $rres, error => archive_error_string($!archive);
    }
    if &callback($e) {
      if $destpath.defined && $destpath ne '' {
        $e!Archive::Libarchive::Entry::safe;
        $e.pathname: $*SPEC.catdir($destpath, $e.pathname);
      }
      my $wres = archive_write_header $!ext, $e.entry;
      if $wres == ARCHIVE_OK {
        if $e.size > 0 {
          self!copy-data;
        }
      } else {
        fail X::Libarchive.new: errno => $wres, error => archive_error_string($!ext);
      }
      my $fres = archive_write_finish_entry $!ext;
      if $fres != ARCHIVE_OK {
        fail X::Libarchive.new: errno => $fres, error => archive_error_string($!ext);
      }
      $res = True;
    }
  }
  return $res;
}

multi method extract(Str $destpath? --> Bool)
{
  my $e = Archive::Libarchive::Entry.new;
  while (my $rres = archive_read_next_header $!archive, $e.entry) == ARCHIVE_OK {
    last if $rres == ARCHIVE_EOF;
    if $rres != ARCHIVE_OK {
      fail X::Libarchive.new: errno => $rres, error => archive_error_string($!archive);
    }
    if $destpath.defined && $destpath ne '' {
      $e!Archive::Libarchive::Entry::safe;
      $e.pathname: $*SPEC.catdir($destpath, $e.pathname);
    }
    my $wres = archive_write_header $!ext, $e.entry;
    if $wres == ARCHIVE_OK {
      if $e.size > 0 {
        self!copy-data;
      }
    } else {
      fail X::Libarchive.new: errno => $wres, error => archive_error_string($!ext);
    }
    my $fres = archive_write_finish_entry $!ext;
    if $fres != ARCHIVE_OK {
      fail X::Libarchive.new: errno => $fres, error => archive_error_string($!ext);
    }
  }
  return True;
}

method lib-version
{
  {
    ver     => archive_version_number,
    strver  => archive_version_string,
    details => archive_version_details,
    zlib    => archive_zlib_version,
    liblzma => archive_liblzma_version,
    bzlib   => archive_bzlib_version,
    liblz4  => archive_liblz4_version,
  }
}

=begin pod

=head1 NAME

Archive::Libarchive - High-level bindings to libarchive

=head1 SYNOPSIS
=begin code

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

=end code

=head1 DESCRIPTION

B<Archive::Libarchive> provides a procedural and a OO interface to libarchive using Archive::Libarchive::Raw.

As the Libarchive site (L<http://www.libarchive.org/>) states, its implementation is able to:

=item Read a variety of formats, including tar, pax, cpio, zip, xar, lha, ar, cab, mtree, rar, and ISO images.
=item Write tar, pax, cpio, zip, xar, ar, ISO, mtree, and shar archives.
=item Handle automatically archives compressed with gzip, bzip2, lzip, xz, lzma, or compress.


=head2 new(LibarchiveOp :$operation!, Any :$file?, Int :$flags?, Str :$format?, :@filters?)

Creates an B<Archive::Libarchive> object. It takes one I<mandatory> argument:
B<operation>, what kind of operation will be performed.

The list of possible operations is provided by the B<LibarchiveOp> enum:

=item LibarchiveRead: open the archive to list its content.
=item LibarchiveWrite: create a new archive. The file must not be already present.
=item LibarchiveOverwrite: create a new archive. The file will be overwritten if present.
=item LibarchiveExtract: extract the archive content.

When extracting one can specify some options to be applied to the newly created files. The default options are:

B<ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS>

Those constants are defined in Archive::Libarchive::Constants, part of the Archive::Libarchive::Raw
distribution.
More details about those operation modes can be found on the libarchive site: L<http://www.libarchive.org/>

If the optional argument B<$file> is provided, then it will be opened; if not provided
during the initialization, the program must call the B<open> method later.

If the optional B<$format> argument is provided, then the object will select that specific format
while dealing with the archive.

List of possible read formats:

=item 7zip
=item ar
=item cab
=item cpio
=item empty
=item gnutar
=item iso9660
=item lha
=item mtree
=item rar
=item raw
=item tar
=item warc
=item xar
=item zip

List of possible write formats:

=item 7zip
=item ar
=item cpio
=item gnutar
=item iso9660
=item mtree
=item pax
=item raw
=item shar
=item ustar
=item v7tar
=item warc
=item xar
=item zip

If the optional B<@filters> parameter is provided, then the object will add those filter to the archive.
Multiple filters can be specified, so a program can manage a file.tar.gz.uu for example.
The order of the filters is significant, in order to correctly deal with such files as I<file.tar.uu.gz> and
I<file.tar.gz.uu>.

List of possible read filters:

=item bzip2
=item compress
=item gzip
=item grzip
=item lrzip
=item lz4
=item lzip
=item lzma
=item lzop
=item none
=item rpm
=item uu
=item xz

List of possible write filters:

=item b64encode
=item bzip2
=item compress
=item grzip
=item gzip
=item lrzip
=item lz4
=item lzip
=item lzma
=item lzop
=item none
=item uuencode
=item xz

=head3 Note

Recent versions of libarchive implement an automatic way to determine the best mix of format and filters.
If one's using a pretty recent libarchive, both $format and @filters may be omitted: the B<new> method will
determine automatically the right combination of parameters.
Older versions though don't have that capability and the programmer has to define explicitly both parameters.

=head2 open(Str $filename!, Int :$size?, :$format?, :@filters?)
=head2 open(Buf $data!)

Opens an archive; the first form is used on files, while the second one is used to open an archive that
resides in memory.

The first argument is always mandatory, while the other ones might been omitted.

$size is the size of the internal buffer and defaults to 10240 bytes.

=head2 close

Closes the internal archive object, frees the memory and cleans up.

=head2 extract-opts(Int $flags?)

Sets the options for the files created when extracting files from an archive.
The default options are:

B<ARCHIVE_EXTRACT_TIME +| ARCHIVE_EXTRACT_PERM +| ARCHIVE_EXTRACT_ACL +| ARCHIVE_EXTRACT_FFLAGS>

=head2 next-header(Archive::Libarchive::Entry:D $e! --> Bool)

When reading an archive this method fills the Entry object and returns True till it reaches the end of the archive.

The Entry object is pubblicly defined inside the Archive::Libarchive module. It's initialized this way:

=begin code
my Archive::Libarchive::Entry $e .= new;
=end code

So a complete archive lister can be implemented in few lines:

=begin code
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
=end code

=head2 data-skip(--> Int)

When reading an archive this method skips file data to jump to the next header.
It returns B<ARCHIVE_OK> or B<ARCHIVE_EOF> (defined in Archive::Libarchive::Constants)

=head2 write-header(Str $file, Int :$size?, Int :$filetype?, Int :$perm?, Int :$atime?, Int :$mtime?, Int :$ctime?, Int :$birthtime?, Int :$uid?, Int :$gid?, Str :$uname?, Str :$gname?  --> Bool)

When creating an archive this method writes the header entry for the file being inserted into the archive.
The only mandatory argument is the file name, every other argument has a reasonable default.
More details can be found on the libarchive site.

Each optional argument is available as a method of the Archive::Libarchive::Entry object and it can be set when needed.

=head2 write-data(Str $path --> Bool)

When creating an archive this method writes the data for the file being inserted into the archive.

=head2 extract(Str $destpath? --> Bool)
=head2 extract(&callback:(Archive::Libarchive::Entry $e --> Bool)!, Str $destpath? --> Bool)

When extracting files from an archive this method does all the dirty work.
If used in the first form it extracts all the files.
The second form takes a callback function, which receives a Archive::Libarchive::Entry object.

For example, this will extract only the file whose name is I<test2>:

=begin code
$a.extract: sub (Archive::Libarchive::Entry $e --> Bool) { $e.pathname eq 'test2' };
=end code

In both cases one can specify the directory into which the files will be extracted.

=head2 lib-version

Returns a hash with the version number of libarchive and of each library used internally.

=head2 Errors

When the underlying library returns an error condition, the methods will return a Failure object, which can
be trapped and the exception can be analyzed and acted upon.

The exception object has two fields: $errno and $error, and return a message stating the error number and
the associated message as delivered by libarchive.

=head1 Prerequisites

This module requires the libarchive library to be installed. Please follow the
instructions below based on your platform:

=head2 Debian Linux

=begin code
sudo apt-get install libarchive13
=end code

The module uses Archive::Libarchive::Raw which looks for a library called libarchive.so, or whatever it finds in
the environment variable B<PERL6_LIBARCHIVE_LIB> (provided that the library one chooses uses the same API).

=head1 Installation

To install it using Panda (a module management tool):

=begin code
$ panda update
$ panda install Archive::Libarchive
=end code

To install it using zef (a module management tool):

=begin code
$ zef update
$ zef install Archive::Libarchive
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "perl6 -Ilib"
=end code

or

=begin code
$ prove6
=end code

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
