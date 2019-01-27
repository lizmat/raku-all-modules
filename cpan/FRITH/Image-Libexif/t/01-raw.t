#!/usr/bin/env perl6

use Test;
use lib 'lib';
use Image::Libexif::Raw;
use Image::Libexif::Constants;
use NativeHelpers::Blob;
use NativeCall;

constant AUTHOR = ?%*ENV<TEST_AUTHOR>;

my $file = 't/sample01.jpg';
my ExifData ($exif, $exif1);

subtest {
  $exif = exif_data_new();
  isa-ok $exif, Image::Libexif::Raw::ExifData, 'simple initialization';
  exif_data_free($exif);
  $exif = exif_data_new_from_file($file);
  isa-ok $exif, Image::Libexif::Raw::ExifData, 'initialization from file';
  my $jpeg = slurp $file, :bin;
  $exif1 = exif_data_new_from_data(pointer-to($jpeg), $jpeg.bytes);
  isa-ok $exif1, Image::Libexif::Raw::ExifData, 'initialization from memory data';
}, 'initialization';

subtest {
  is exif_byte_order_get_name(EXIF_BYTE_ORDER_MOTOROLA), 'Motorola', 'get byte order name';
  if AUTHOR {
    cmp-ok exif_data_get_byte_order($exif1), '==', EXIF_BYTE_ORDER_INTEL, 'get exif data byte order';
  }
  exif_data_set_byte_order($exif1, EXIF_BYTE_ORDER_MOTOROLA);
  cmp-ok exif_data_get_byte_order($exif1), '==', EXIF_BYTE_ORDER_MOTOROLA, 'set exif data byte order';
  is exif_ifd_get_name(EXIF_IFD_INTEROPERABILITY), 'Interoperability', 'get ifd name';
  is exif_content_get_ifd($exif1.ifd[0]), 0, 'read ifd';
  exif_data_free($exif1);
}, 'info';

subtest {
  cmp-ok exif_data_get_data_type($exif), '==', EXIF_DATA_TYPE_COUNT, 'get data type';
  exif_data_set_data_type($exif, EXIF_DATA_TYPE_COMPRESSED);
  cmp-ok exif_data_get_data_type($exif), '==', EXIF_DATA_TYPE_COMPRESSED, 'set data type';
}, 'data type';

subtest {
  is exif_data_option_get_name(EXIF_DATA_OPTION_IGNORE_UNKNOWN_TAGS), 'Ignore unknown tags', 'get data option name';
  is exif_data_option_get_description(EXIF_DATA_OPTION_IGNORE_UNKNOWN_TAGS),
    'Ignore unknown tags when loading EXIF data.', 'get data option description';
}, 'data option';

subtest {
  is $exif.ifd[0].count, 11, 'ifd0';
  is $exif.ifd[1].count,  6, 'ifd1';
  is $exif.ifd[2].count, 35, 'ifd2';
  is $exif.ifd[3].count,  0, 'ifd3';
  is $exif.ifd[4].count,  2, 'ifd4';
}, 'number of tags';

subtest {
  my ExifEntry $entry = exif_content_get_entry($exif.ifd[0], EXIF_TAG_MAKE);
  isa-ok $entry, Image::Libexif::Raw::ExifEntry, 'get entry';
  cmp-ok $entry.tag, '==', EXIF_TAG_MAKE, 'tag number';
  cmp-ok $entry.format, '==', EXIF_FORMAT_ASCII, 'tag format';
  is $entry.components, 9, 'tag components';
  is $entry.size, $entry.components, 'tag size';
  my Buf $buf .= allocate: $entry.components, 0;
  is exif_entry_get_value($entry, $buf, 9), 'FUJIFILM', 'tag value';
  is exif_format_get_name(EXIF_FORMAT_RATIONAL), 'Rational', 'format name';
  is exif_format_get_size(EXIF_FORMAT_RATIONAL), 8, 'format size';
}, 'tags in ifd0';

subtest {
  my $content1 = exif_content_new;
  isa-ok $content1, Image::Libexif::Raw::ExifContent, 'new content';

  my @collected;
  sub callback(ExifEntry $entry, Pointer $dummy) {
    -> ExifEntry $entry, Str $data {
      my Buf $buf .= allocate: 100, 0;
      @collected.push: "$data: " ~ exif_entry_get_value($entry, $buf, 100);
    }($entry, $file);
  }
  my Pointer $dummy .= new;
  my ExifContent $content = $exif.ifd[0];
  exif_content_foreach_entry($content, &callback, $dummy);
  is @collected.head, 't/sample01.jpg: FUJIFILM', 'exif_content_foreach_entry';

  my ExifEntry $entryin = exif_entry_new();
  exif_content_add_entry($content, $entryin);
  exif_entry_initialize($entryin, EXIF_TAG_IMAGE_DESCRIPTION);
  exif_set_short($entryin.data, EXIF_BYTE_ORDER_INTEL, 1);
  my ExifEntry $entryout = exif_content_get_entry($content, EXIF_TAG_IMAGE_DESCRIPTION);
  isa-ok $entryout, Image::Libexif::Raw::ExifEntry, 'get entry';
  cmp-ok exif_get_short($entryout.data, EXIF_BYTE_ORDER_INTEL), '==', 1, 'set and get tag';
  exif_content_remove_entry($content, $entryin);
  $entryout = exif_content_get_entry($content, EXIF_TAG_IMAGE_DESCRIPTION);
  nok $entryout.defined, 'exif_content_remove_entry';
}, 'exifcontent';

subtest {
  my ExifEntry $entry1 = exif_entry_new();
  isa-ok $entry1, Image::Libexif::Raw::ExifEntry, 'new entry';
  exif_entry_initialize($entry1, EXIF_TAG_IMAGE_DESCRIPTION);
  cmp-ok ($entry1.tag, $entry1.format, $entry1.components, $entry1.size).all, '==', 0, 'entry initialization';
  exif_entry_free($entry1);
}, 'entry';

subtest {
  my $mnote = exif_data_get_mnote_data($exif);
  isa-ok $mnote, Image::Libexif::Raw::ExifMnoteData, 'get mnote data';
  is exif_mnote_data_count($mnote), 33, 'mnote data count';
  is exif_mnote_data_get_description($mnote, 1), 'This number is unique and based on the date of manufacture.',
      'mnote data description';
  is exif_mnote_data_get_id($mnote, 1), 16, 'mnote get id';
  is exif_mnote_data_get_name($mnote, 4), 'WhiteBalance', 'mnote get name';
  is exif_mnote_data_get_title($mnote, 4), 'White Balance', 'mnote get title';
  my $val = Buf.new(1..1024);
  exif_mnote_data_get_value($mnote, 4, $val, 1024);
  is $val.subbuf(0, 4).decode('utf-8'), 'Auto', 'mnote data get value';
}, 'mnote';

subtest {
  my $log = exif_log_new();
  isa-ok $log, Image::Libexif::Raw::ExifLog, 'new log';
  is exif_log_code_get_title(EXIF_LOG_CODE_CORRUPT_DATA), 'Corrupt data', 'get log title';
  is exif_log_code_get_message(EXIF_LOG_CODE_CORRUPT_DATA), 'The data provided does not follow the specification.',
      'get log message';
  my ExifContent $content = $exif.ifd[0];
  exif_content_log($content, $log);
  exif_log_free($log);
}, 'log';

subtest {
  is exif_tag_get_name(EXIF_TAG_GPS_LATITUDE_REF), 'InteroperabilityIndex', 'get tag name';
  is exif_tag_from_name('InteroperabilityIndex'), 1, 'get tag from name';
  is exif_tag_get_title_in_ifd(EXIF_TAG_GPS_LATITUDE_REF, EXIF_IFD_INTEROPERABILITY), 'Interoperability Index',
      'get tag title in ifd';
  is exif_tag_get_name_in_ifd(EXIF_TAG_GPS_LATITUDE_REF, EXIF_IFD_INTEROPERABILITY), 'InteroperabilityIndex',
      'get tag name in ifd';
  is exif_tag_get_description_in_ifd(EXIF_TAG_GPS_LATITUDE_REF, EXIF_IFD_INTEROPERABILITY),
      'Indicates the identification of the Interoperability rule. Use "R98" for stating ExifR98 Rules. ' ~
      'Four bytes used including the termination code (NULL). see the separate volume of Recommended Exif ' ~
      'Interoperability Rules (ExifR98) for other tags used for ExifR98.',
      'get tag description in ifd';
  is exif_tag_get_support_level_in_ifd(EXIF_TAG_GPS_LATITUDE_REF, EXIF_IFD_INTEROPERABILITY, EXIF_DATA_TYPE_UNKNOWN),
      EXIF_SUPPORT_LEVEL_OPTIONAL.value, 'get tag support level in ifd';
}, 'tag';

subtest {
  my $el = exif_loader_new;
  isa-ok $el, Image::Libexif::Raw::ExifLoader, 'new ExifLoader';
  exif_loader_write_file($el, $file);
  my $exif2 = exif_loader_get_data($el);
  isa-ok $exif2, Image::Libexif::Raw::ExifData, 'load and get data from file';
  my Pointer[uint8] $buf .= new;
  my uint32 $len;
  exif_loader_get_buf($el, $buf, $len);
  cmp-ok $len, '==', 2118, 'buffer length';
  cmp-ok $buf[^10], '~~', (69, 120, 105, 102, 0, 0, 73, 73, 42, 0), 'buffer content';
}, 'exifloader';

if AUTHOR {
  exif_data_dump($exif);
  exif_content_dump($exif.ifd[0], 2);
}

done-testing;
