use v6;
unit class Image::Libexif:ver<0.1.0>;

use Image::Libexif::Raw;
use Image::Libexif::Constants;
use NativeCall;
use NativeHelpers::Blob;

class X::Libexif is Exception
{
  has Int $.errno;
  has Str $.error;

  method message { "Error {$!errno}: $!error"; }
}

has ExifData $!exif;

our %tagnames is export(:tagnames) =
  0x0001 => 'Interoperability index',
  0x0002 => 'Interoperability version',
  0x00fe => 'New subfile type',
  0x0100 => 'Image width',
  0x0101 => 'Image length',
  0x0102 => 'Bits per sample',
  0x0103 => 'Compression',
  0x0106 => 'Photometric interpretation',
  0x010a => 'Fill order',
  0x010d => 'Document name',
  0x010e => 'Image description',
  0x010f => 'Make',
  0x0110 => 'Model',
  0x0111 => 'Strip offsets',
  0x0112 => 'Orientation',
  0x0115 => 'Samples per pixel',
  0x0116 => 'Rows per strip',
  0x0117 => 'Strip byte counts',
  0x011a => 'X resolution',
  0x011b => 'Y resolution',
  0x011c => 'Planar configuration',
  0x0128 => 'Resolution unit',
  0x012d => 'Transfer function',
  0x0131 => 'Software',
  0x0132 => 'Date time',
  0x013b => 'Artist',
  0x013e => 'White point',
  0x013f => 'Primary chromaticities',
  0x014a => 'Sub ifds',
  0x0156 => 'Transfer range',
  0x0200 => 'Jpeg proc',
  0x0201 => 'Jpeg interchange format',
  0x0202 => 'Jpeg interchange format length',
  0x0211 => 'Ycbcr coefficients',
  0x0212 => 'Ycbcr sub sampling',
  0x0213 => 'Ycbcr positioning',
  0x0214 => 'Reference black white',
  0x02bc => 'Xml packet',
  0x1000 => 'Related image file format',
  0x1001 => 'Related image width',
  0x1002 => 'Related image length',
  0x828d => 'Cfa repeat pattern dim',
  0x828e => 'Cfa pattern',
  0x828f => 'Battery level',
  0x8298 => 'Copyright',
  0x829a => 'Exposure time',
  0x829d => 'Fnumber',
  0x83bb => 'Iptc naa',
  0x8649 => 'Image resources',
  0x8769 => 'Exif ifd pointer',
  0x8773 => 'Inter color profile',
  0x8822 => 'Exposure program',
  0x8824 => 'Spectral sensitivity',
  0x8825 => 'Gps info ifd pointer',
  0x8827 => 'Iso speed ratings',
  0x8828 => 'Oecf',
  0x882a => 'Time zone offset',
  0x9000 => 'Exif version',
  0x9003 => 'Date time original',
  0x9004 => 'Date time digitized',
  0x9101 => 'Components configuration',
  0x9102 => 'Compressed bits per pixel',
  0x9201 => 'Shutter speed value',
  0x9202 => 'Aperture value',
  0x9203 => 'Brightness value',
  0x9204 => 'Exposure bias value',
  0x9205 => 'Max aperture value',
  0x9206 => 'Subject distance',
  0x9207 => 'Metering mode',
  0x9208 => 'Light source',
  0x9209 => 'Flash',
  0x920a => 'Focal length',
  0x9214 => 'Subject area',
  0x9216 => 'Tiff ep standard id',
  0x927c => 'Maker note',
  0x9286 => 'User comment',
  0x9290 => 'Sub sec time',
  0x9291 => 'Sub sec time original',
  0x9292 => 'Sub sec time digitized',
  0x9c9b => 'Xp title',
  0x9c9c => 'Xp comment',
  0x9c9d => 'Xp author',
  0x9c9e => 'Xp keywords',
  0x9c9f => 'Xp subject',
  0xa000 => 'Flash pix version',
  0xa001 => 'Color space',
  0xa002 => 'Pixel x dimension',
  0xa003 => 'Pixel y dimension',
  0xa004 => 'Related sound file',
  0xa005 => 'Interoperability ifd pointer',
  0xa20b => 'Flash energy',
  0xa20c => 'Spatial frequency response',
  0xa20e => 'Focal plane x resolution',
  0xa20f => 'Focal plane y resolution',
  0xa210 => 'Focal plane resolution unit',
  0xa214 => 'Subject location',
  0xa215 => 'Exposure index',
  0xa217 => 'Sensing method',
  0xa300 => 'File source',
  0xa301 => 'Scene type',
  0xa302 => 'New cfa pattern',
  0xa401 => 'Custom rendered',
  0xa402 => 'Exposure mode',
  0xa403 => 'White balance',
  0xa404 => 'Digital zoom ratio',
  0xa405 => 'Focal length in 35mm film',
  0xa406 => 'Scene capture type',
  0xa407 => 'Gain control',
  0xa408 => 'Contrast',
  0xa409 => 'Saturation',
  0xa40a => 'Sharpness',
  0xa40b => 'Device setting description',
  0xa40c => 'Subject distance range',
  0xa420 => 'Image unique id',
  0xa500 => 'Gamma',
  0xc4a5 => 'Print image matching',
  0xea1c => 'Padding';

submethod BUILD(Str :$file?, Buf :$data?)
{
  with $file {
    if $file.IO.f {
      $!exif = exif_data_new_from_file $file;
    } else {
      fail X::Libexif.new: errno => 1, error => "File $file not found";
    }
  } orwith $data {
    $!exif = exif_data_new_from_data nativecast(Pointer[uint8], $data), $data.bytes;
  } else {
    $!exif = exif_data_new;
  }
}

method open(Str $file!)
{
  fail X::Libexif.new: errno => 1, error => "File $file not found" if ! $file.IO.e;
  $!exif = exif_data_new_from_file $file;
  self;
}

method load(Buf $buffer!)
{
  exif_data_load_data $!exif, pointer-to($buffer), $buffer.bytes;
  self;
}

method info(--> Hash)
{
  my %info;
  %info<ordercode> = exif_data_get_byte_order $!exif;
  %info<orderstr> = exif_byte_order_get_name %info<ordercode>;
  %info<datatype> = exif_data_get_data_type $!exif;
  %info<tagcount> = $!exif.ifd[EXIF_IFD_0].count +
                    $!exif.ifd[EXIF_IFD_1].count +
                    $!exif.ifd[EXIF_IFD_EXIF].count +
                    $!exif.ifd[EXIF_IFD_GPS].count +
                    $!exif.ifd[EXIF_IFD_INTEROPERABILITY].count;
  %info;
}

method close
{
  with $!exif {
    exif_data_free $!exif;
  }
}

constant IMAGE_INFO            is export = 0;
constant CAMERA_INFO           is export = 1;
constant SHOOT_INFO            is export = 2;
constant GPS_INFO              is export = 3;
constant INTEROPERABILITY_INFO is export = 4;

multi method lookup(Int $tag!, Int $group! --> Str)
{
  my ExifEntry $entry = exif_content_get_entry($!exif.ifd[$group], $tag);
  my Buf $buf .= allocate: 1024, 0;
  exif_entry_get_value($entry, $buf, 1024);
}

multi method lookup(Int $tag! --> Str)
{
  my ExifEntry $entry = exif_content_get_entry($!exif.ifd[EXIF_IFD_0], $tag) ||
  exif_content_get_entry($!exif.ifd[EXIF_IFD_1], $tag) ||
  exif_content_get_entry($!exif.ifd[EXIF_IFD_EXIF], $tag) ||
  exif_content_get_entry($!exif.ifd[EXIF_IFD_GPS], $tag) ||
  exif_content_get_entry($!exif.ifd[EXIF_IFD_INTEROPERABILITY], $tag);
  my Buf $buf .= allocate: 1024, 0;
  exif_entry_get_value($entry, $buf, 1024);
}

method tags(Int $group! where 0 <= * < 5, :$tagdesc? --> Hash)
{
  my %tags;
  my Buf $buf .= allocate: 100, 0;

  sub entrycallback (ExifEntry $entry, Pointer $dummy) {
    my $val = exif_entry_get_value($entry, $buf, 100).trim;
    if $tagdesc {
      my ($desc, $prev);
      for ExifIfd.enums.values.sort -> $id {
        my $out = exif_tag_get_description_in_ifd($entry.tag, $id);
        if $out.defined {
          if $prev.defined && $out eq $prev {
            last;
          } else {
            %tags{$entry.tag.fmt('0x%04x')} = [$val, $out];
            $prev = $out;
          }
        }
      }
    } else {
      %tags{$entry.tag.fmt('0x%04x')} = $val;
    }
  }

  my Pointer $dummy .= new;
  my ExifContent $content = $!exif.ifd[$group];
  exif_content_foreach_entry($content, &entrycallback, $dummy);
  %tags;
}

method notes(--> Array)
{
  my @mnotes;
  my $mnote = exif_data_get_mnote_data($!exif);
  my $notes = exif_mnote_data_count($mnote);
  my $val = Buf.new(1..1024);
  for 1..$notes -> $note {
    @mnotes.push:
      (exif_mnote_data_get_description($mnote, $note) // ' ') ~ ' ' ~
      (exif_mnote_data_get_name($mnote, $note) // ' ') ~ ' ' ~
      (exif_mnote_data_get_title($mnote, $note) // ' ') ~ ' ' ~
      (exif_mnote_data_get_value($mnote, $note, $val, 1024) // '');
  }
  @mnotes;
}

method alltags(Bool :$tagdesc? --> Array)
{
  my @tags;
  @tags[$_] = self.tags($_, :$tagdesc) for ^5;
  @tags;
}

method thumbnail($file where { .IO.f // fail X::Libexif.new: errno => 1, error => "File $_ not found" } --> Blob)
{
  thumbnail($file);
}

sub thumbnail($file where { .IO.f // fail X::Libexif.new: errno => 1, error => "File $_ not found" } --> Blob)
  is export(:thumbnail)
{
  my $l = exif_loader_new() // fail X::Libexif.new: errno => 2, error => ’Can't create an exif loader‘;
  exif_loader_write_file($l, $file);
  my $ed = exif_loader_get_data($l) // fail X::Libexif.new: errno => 3, error => ’Can't get the exif data‘;
  exif_loader_unref($l);
  if $ed.data && $ed.size {
    my $data = blob-from-pointer($ed.data, :elems($ed.size), :type(Blob));
    return $data;
  } else {
    fail X::Libexif.new: errno => 4, error => "No EXIF thumbnail in file $file";
  }
  exif_data_unref($ed);
}

=begin pod

=head1 NAME

Image::Libexif - High-level bindings to libexif

=head1 SYNOPSIS

=begin code

use v6;

use Image::Libexif :tagnames;
use Image::Libexif::Constants;

sub MAIN($file! where { .IO.f // die "file $file not found" })
{
  my Image::Libexif $e .= new: :$file;
  my @tags := $e.alltags: :tagdesc;
  say @tags».keys.flat.elems ~ ' tags found';
  for ^EXIF_IFD_COUNT -> $group {
    say "Group $group: " ~ «'Image info' 'Camera info' 'Shoot info' 'GPS info' 'Interoperability info'»[$group];
    for %(@tags[$group]).kv -> $k, @v {
      say "%tagnames{$k.Int}: @v[1] => @v[0]";
    }
  }
}

=end code

=begin code

use v6;

use Concurrent::File::Find;
use Image::Libexif;
use Image::Libexif::Constants;

#| This program displays the EXIF date and time for every file in a directory tree
sub MAIN($dir where {.IO.d // die "$dir not found"})
{
  my @files := find $dir, :extension('jpg'), :exclude-dir('thumbnails') :file, :!directory;
  @files.race.map: -> $file {
      my Image::Libexif $e .= new: :file($file);
      try say "$file " ~ $e.lookup(EXIF_TAG_DATE_TIME_ORIGINAL); # don't die if no EXIF is present
      $e.close;
    }
}

=end code

=head1 DESCRIPTION

Image::Libexif provides an OO interface to libexif.

=head2 use Image::Libexif;
=head2 use Image::Libexif :tagnames;

If asked to import the additional symbol B<tagnames>, Image::Libexif will make available the Hash %tagnames, which
has tag numbers as keys and a short description as values.

=head2 new(Str :$file?, Buf :$data?)

Creates an Image::Libexif object.

If the optional argument B<$file> is provided, then it will be opened and read; if not provided
during the initialization, the program may call the B<open> method later.
If the optional argument B<data> is provided, then the object will be initialized from the provided data; if not
provided during the initialization, the program may call the B<load> method later.

=head2 open(Str $file!)

Opens a file and reads it into an initialiazed object (when no file or data has been provided during initialization).

=head2 load(Buf $data!)

Reads the data into an initialiazed object (when no file or data has been provided during initialization).

=head2 close

Closes the internal libexif object, frees the memory and cleans up.

=head2 info(--> Hash)

Gathers some info:

=item ordercode - the byte order as a code
=item orderstr  - the byte order as a string
=item datatype  - the data type
=item tagcount  - the number of tags

=head2 lookup(Int $tag!, Int $group! --> Str)
=head2 lookup(Int $tag! --> Str)

Looks up a tag in a specific group or in all groups. A tag may be present in more than one group.
Group names are available as constants:

=item IMAGE_INFO
=item CAMERA_INFO
=item SHOOT_INFO
=item GPS_INFO
=item INTEROPERABILITY_INFO

=head2 tags(Int $group! where 0 <= * < 5, :$tagdesc? --> Hash)

Delivers all the tags in a specific group into a hash; the keys are the tag numbers.
If the tag description is requested, the hash values are presented as an array [value, tag description].

=head2 alltags(:$tagdesc? --> Array)

Delivers an array of hashes, one for each group.
If the tag description is requested, the hash values are presented as an array [value, tag description].

=head2 notes(--> Array)

Reads the Maker Note data as an array of strings.
Each string is a concatenation of the note description, name, title, and value.

=head2 method thumbnail($file where { .IO.f // fail X::Libexif.new: errno => 1, error => "File $_ not found" } --> Blob)
=head2 sub thumbnail($file where { .IO.f // fail X::Libexif.new: errno => 1, error => "File $_ not found" } --> Blob) is export(:thumbnail)

Returns the thumbnail found in the original file, if any, as a Blob.
This functionality is available as a method and a sub, since the library doesn't really need a fully initialized
exif object.
To use the sub import it explicitly: B<use Image::Libexif :thumbnail;>.

=head2 Errors

There one case when an error may be returned: trying to open a non-existent file.
This can happen while initializing an object with .new() and calling the .open() method.
In both cases the method will return a Failure object, which can
be trapped and the exception can be analyzed and acted upon.

=head1 Prerequisites

This module requires the libexif library to be installed. Please follow the
instructions below based on your platform:

=head2 Debian Linux

=begin code
sudo apt-get install libexif12
=end code

The module looks for a library called libexif.so.

=head1 Installation

To install it using zef (a module management tool):

=begin code
$ zef install Image::Libexif
=end code

=head1 Testing

To run the tests:

=begin code
$ prove -e "perl6 -Ilib"
=end code

=head1 Author

Fernando Santagata

=head1 License

The Artistic License 2.0

=end pod
