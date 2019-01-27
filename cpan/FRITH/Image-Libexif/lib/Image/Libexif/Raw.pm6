use v6;

unit module Image::Libexif::Raw:ver<0.1.0>;

use NativeCall;
use Image::Libexif::Constants;

constant LIB = ('exif', v12);

class ExifDataPrivate is repr('CPointer') { * }
class ExifMnoteData is repr('CPointer') { * }
class ExifLog is repr('CPointer') { * }
class ExifLoader is repr('CPointer') { * }

class ExifEntry is repr('CStruct') is export {
  has int32 $.tag;
  has int32 $.format;
  has uint64 $.components;
  has Pointer[uint8] $.data;
  has uint32 $.size;
  has Pointer $.parent; # ExifContent
  has ExifDataPrivate $.priv;
}

class ExifContent is repr('CStruct') is export {
  has ExifEntry $.entries is rw;
  has uint32 $.count;
  has Pointer $.parent; # ExifData
  has ExifDataPrivate $.priv;
}

class ExifData is repr('CStruct') is export {
  HAS ExifContent @.ifd[EXIF_IFD_COUNT] is CArray;
  has Pointer[uint8] $.data;
  has uint32 $.size;
  has ExifDataPrivate $.priv;
}

sub exif_data_new(--> ExifData) is native(LIB) is export { * }
sub exif_data_new_from_file(Str $path --> ExifData) is native(LIB) is export { * }
sub exif_data_new_from_data(Pointer $data, uint32 $size --> ExifData) is native(LIB) is export { * }
sub exif_data_load_data(ExifData $exif, Pointer $d, uint32 $size) is native(LIB) is export { * }
sub exif_data_save_data(ExifData $exif, Pointer $d is rw, uint8 $ds is rw) is native(LIB) is export { * }
sub exif_data_dump(ExifData $data) is native(LIB) is export { * }
sub exif_data_ref(ExifData $exif) is native(LIB) is export { * }
sub exif_data_unref(ExifData $exif) is native(LIB) is export { * }
sub exif_data_free(ExifData $exif) is native(LIB) is export { * }
sub exif_data_get_byte_order(ExifData $exif --> uint32) is native(LIB) is export { * }
sub exif_data_set_byte_order(ExifData $exif, uint32 $order) is native(LIB) is export { * }
sub exif_data_get_mnote_data(ExifData $exif --> ExifMnoteData) is native(LIB) is export { * }
sub exif_data_fix(ExifData $exif) is native(LIB) is export { * }
sub exif_data_foreach_content(ExifData $exif, &func (ExifContent $content, Pointer $dummy1), Pointer $dummy2) is native(LIB) is export { * }
sub exif_data_option_get_name(int32 $o --> Str) is native(LIB) is export { * }
sub exif_data_option_get_description(int32 $o --> Str) is native(LIB) is export { * }
sub exif_data_set_option(ExifData $exif, int32 $o) is native(LIB) is export { * }
sub exif_data_unset_option(ExifData $exif, int32 $o) is native(LIB) is export { * }
sub exif_data_set_data_type(ExifData $exif, int32 $datatype) is native(LIB) is export { * }
sub exif_data_get_data_type(ExifData $exif --> int32) is native(LIB) is export { * }
sub exif_data_log(ExifData $exif, ExifLog $log) is native(LIB) is export { * }

sub exif_content_new(--> ExifContent) is native(LIB) is export { * }
sub exif_content_ref(ExifContent $content) is native(LIB) is export { * }
sub exif_content_unref(ExifContent $content) is native(LIB) is export { * }
sub exif_content_free(ExifContent $content) is native(LIB) is export { * }
sub exif_content_add_entry(ExifContent $content, ExifEntry $entry) is native(LIB) is export { * }
sub exif_content_get_entry(ExifContent $content, uint32 $tag --> ExifEntry) is native(LIB) is export { * }
sub exif_content_remove_entry(ExifContent $content, ExifEntry $entry) is native(LIB) is export { * }
sub exif_content_fix(ExifContent $content) is native(LIB) is export { * }
sub exif_content_log(ExifContent $content, ExifLog $log) is native(LIB) is export { * }

sub exif_entry_new(--> ExifEntry) is native(LIB) is export { * }
sub exif_entry_ref(ExifEntry $entry) is native(LIB) is export { * }
sub exif_entry_unref(ExifEntry $entry) is native(LIB) is export { * }
sub exif_entry_free(ExifEntry $entry) is native(LIB) is export { * }
sub exif_entry_initialize(ExifEntry $entry, uint32 $tag) is native(LIB) is export { * }
sub exif_entry_fix(ExifEntry $entry) is native(LIB) is export { * }
sub exif_entry_get_value(ExifEntry $entry, Buf $val, uint32 $maxlen --> Str) is native(LIB) is export { * }
sub exif_entry_dump(ExifEntry $entry, uint32 $indent) is native(LIB) is export { * }

sub exif_ifd_get_name(uint32 $ifd --> Str) is native(LIB) is export { * }
sub exif_format_get_name(int32 $format --> Str) is native(LIB) is export { * }
sub exif_format_get_size(int32 $format --> uint8) is native(LIB) is export { * }

sub exif_content_get_ifd(ExifContent $exifcontent --> uint32) is native(LIB) is export { * }
sub exif_content_dump(ExifContent $exifcontent, uint32 $indent) is native(LIB) is export { * }
sub exif_content_foreach_entry(ExifContent $exifcontent, &func (ExifEntry $entry, Pointer $dummy1), Pointer $dummy2) is native(LIB) is export { * }

sub exif_byte_order_get_name(uint32 $order --> Str) is native(LIB) is export { * }

sub exif_log_new(--> ExifLog) is native(LIB) is export { * }
sub exif_log_ref(ExifLog $log) is native(LIB) is export { * }
sub exif_log_unref(ExifLog $log) is native(LIB) is export { * }
sub exif_log_free(ExifLog $log) is native(LIB) is export { * }
sub exif_log_code_get_title(uint32 $code --> Str) is native(LIB) is export { * }
sub exif_log_code_get_message(uint32 $code --> Str) is native(LIB) is export { * }

sub exif_mnote_data_ref(ExifMnoteData $mnote) is native(LIB) is export { * }
sub exif_mnote_data_unref(ExifMnoteData $mnote) is native(LIB) is export { * }
sub exif_mnote_data_count(ExifMnoteData $mnote --> uint32) is native(LIB) is export { * }
sub exif_mnote_data_get_id(ExifMnoteData $mnote, uint32 $n --> uint32) is native(LIB) is export { * }
sub exif_mnote_data_get_name(ExifMnoteData $mnote, uint32 $n --> Str) is native(LIB) is export { * }
sub exif_mnote_data_get_title(ExifMnoteData $mnote, uint32 $n --> Str) is native(LIB) is export { * }
sub exif_mnote_data_get_description(ExifMnoteData $mnote, uint32 $n --> Str) is native(LIB) is export { * }
sub exif_mnote_data_get_value(ExifMnoteData $mnote, uint32 $n, Buf $val, uint32 $maxlen --> Str) is native(LIB) is export { * }
sub exif_mnote_data_log(ExifMnoteData $mnote, ExifLog $log) is native(LIB) is export { * }

sub exif_tag_get_name(uint32 $tag --> Str) is native(LIB) is export { * }
sub exif_tag_from_name(Str $name --> uint32) is native(LIB) is export { * }
sub exif_tag_get_name_in_ifd(uint32 $tag, uint32 $ifd --> Str) is native(LIB) is export { * }
sub exif_tag_get_title_in_ifd(uint32 $tag, uint32 $ifd --> Str) is native(LIB) is export { * }
sub exif_tag_get_description_in_ifd(uint32 $tag, uint32 $ifd --> Str) is native(LIB) is export { * }
sub exif_tag_get_support_level_in_ifd(uint32 $tag, uint32 $ifd, uint32 $datatype --> uint32) is native(LIB) is export { * }

sub exif_loader_new(--> ExifLoader) is native(LIB) is export { * }
sub exif_loader_ref(ExifLoader $l) is native(LIB) is export { * }
sub exif_loader_unref(ExifLoader $l) is native(LIB) is export { * }
sub exif_loader_write_file(ExifLoader $l, Str $fname) is native(LIB) is export { * }
sub exif_loader_write(ExifLoader $l, Buf $buf, uint32 $size) is native(LIB) is export { * }
sub exif_loader_reset(ExifLoader $l) is native(LIB) is export { * }
sub exif_loader_get_data(ExifLoader $l --> ExifData) is native(LIB) is export { * }
sub exif_loader_get_buf(ExifLoader $l, Pointer $d is rw, uint32 $ds is rw) is native(LIB) is export { * }
sub exif_loader_log(ExifLoader $l, ExifLog $log) is native(LIB) is export { * }

sub exif_set_short(Pointer $data, uint16 $order, uint8 $value) is native(LIB) is export { * }
sub exif_set_sshort(Pointer $data, int16 $order, uint8 $value) is native(LIB) is export { * }
sub exif_set_long(Pointer $data, uint32 $order, uint8 $value) is native(LIB) is export { * }
sub exif_set_slong(Pointer $data, int32 $order, uint8 $value) is native(LIB) is export { * }
sub exif_get_short(Pointer $data, uint8 $value --> uint16) is native(LIB) is export { * }
sub exif_get_sshort(Pointer $data, uint8 $value --> int16) is native(LIB) is export { * }
sub exif_get_long(Pointer $data, uint8 $value --> uint32) is native(LIB) is export { * }
sub exif_get_slong(Pointer $data, uint8 $value --> int32) is native(LIB) is export { * }

=begin pod

=head1 NAME

Image::Libexif::Raw - A simple interface to libexif

=head1 SYNOPSIS
=begin code

use v6;

use Image::Libexif::Raw;
use Image::Libexif::Constants;
use NativeHelpers::Blob;

#| This program extracts an EXIF thumbnail from an image and saves it into a new file (in the same directory as the original).
sub MAIN($file! where { .IO.f // die "file '$file' not found" })
{
  my $l = exif_loader_new() // die ’Can't create an exif loader‘;
  # Load the EXIF data from the image file
  exif_loader_write_file($l, $file);
  # Get the EXIF data
  my $ed = exif_loader_get_data($l) // die ’Can't get the exif data‘;
  # The loader is no longer needed--free it
  exif_loader_unref($l);
  $l = Nil;
  if $ed.data && $ed.size {
    my $thumb-name = $file;
    $thumb-name ~~ s/\.jpg/_thumb.jpg/;
    my $data = blob-from-pointer($ed.data, :elems($ed.size), :type(Blob));
    spurt $thumb-name, $data, :bin;
  } else {
    say "No EXIF thumbnail in file $file";
  }
  # Free the EXIF data
  exif_data_unref($ed);
}

=end code

=begin code

use v6;

use Image::Libexif::Raw;
use NativeCall;

#| This program dumps the EXIF content of its argument
sub MAIN($file! where { .IO.f // die "file $file not found" })
{
  my ExifData $exif = exif_data_new();
  $exif = exif_data_new_from_file($file);
  my Pointer $dummy .= new;
  exif_data_foreach_content($exif,
    sub (ExifContent $content, Pointer $dummy) {
      -> ExifContent $content {
        exif_content_dump($content, 0);
      }($content);
    },
    $dummy);
}

=end code

=head1 DESCRIPTION

For more details on libexif see L<https://github.com/libexif> and L<https://libexif.github.io/docs.html>.

=head1 Prerequisites

This module requires the libexif library to be installed. Please follow the instructions below based on your platform:

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
