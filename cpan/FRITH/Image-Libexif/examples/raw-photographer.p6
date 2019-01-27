#!/usr/bin/env perl6

use lib 'lib';
use Image::Libexif::Raw;
use Image::Libexif::Constants;

# Perl6 rendition of this C program:
# https://github.com/libexif/libexif/blob/master/contrib/examples/photographer.c

sub show-tag(ExifData $d, $ifd, $tag)
{
  my ExifEntry $entry = exif_content_get_entry($d.ifd[$ifd], $tag);
  if $entry.defined {
    my $buf = Buf.new(1..1024);
    exif_entry_get_value($entry, $buf, $buf.elems);
    my $asstr = $buf.decode('utf-8');
    if $asstr.chars > 0 {
      printf "%s: %s\n", exif_tag_get_name_in_ifd($tag, $ifd), $asstr;
    }
  }
}

sub show-mnote-tag(ExifData $d, $tag)
{
  my $mn = exif_data_get_mnote_data($d);
  if $mn.defined {
    my $num = exif_mnote_data_count($mn);
    loop (my $i = 0; $i < $num; $i++) {
      my $buf = Buf.new(1..1024);
      if exif_mnote_data_get_id($mn, $i) == $tag {
        if exif_mnote_data_get_value($mn, $i, $buf, $buf.elems) {
          my $asstr = $buf.decode('utf-8');
          if $asstr.chars > 0 {
            printf "%s: %s\n", exif_mnote_data_get_title($mn, $i), $asstr;
          }
        }
      }
    }
  }
}

#| This program displays the contents of a number of specific EXIF and MakerNote tags.
#| The tags selected are those that may aid in dentification of the photographer who took the image.
sub MAIN($file! where { .IO.f // die "file '$file' not found" })
{
  my $ed = exif_data_new_from_file($file) || die 'File not readable or no EXIF data in file';
  # Show all the tags that might contain information about the photographer
  try show-tag($ed, EXIF_IFD_0, EXIF_TAG_ARTIST);
  try show-tag($ed, EXIF_IFD_0, EXIF_TAG_XP_AUTHOR);
  try show-tag($ed, EXIF_IFD_0, EXIF_TAG_COPYRIGHT);
  try show-tag($ed, EXIF_IFD_EXIF, EXIF_TAG_USER_COMMENT);
  try show-tag($ed, EXIF_IFD_0, EXIF_TAG_IMAGE_DESCRIPTION);
  try show-tag($ed, EXIF_IFD_1, EXIF_TAG_IMAGE_DESCRIPTION);
  my $entry = exif_content_get_entry($ed.ifd[EXIF_IFD_0], EXIF_TAG_MAKE);
  if $entry.defined {
    my $buf = Buf.new(1..64);
    if exif_entry_get_value($entry, $buf, $buf.elems) {
      my $asstr = $buf.decode('utf-8');
      if $asstr eq 'Canon' {
        show-mnote-tag $ed, 9;
      } elsif $asstr ne ('Asahi Optical Co.,Ltd.', 'PENTAX Corporation').all {
        show-mnote-tag($ed, 0x23);
      }
    }
  }
  exif_data_unref($ed);
}
