use v6;
unit module Image::Libexif::Constants:ver<0.1.0>;

enum ExifDataType is export (:EXIF_DATA_TYPE_UNCOMPRESSED_CHUNKY(0), :EXIF_DATA_TYPE_UNCOMPRESSED_PLANAR(1),
    :EXIF_DATA_TYPE_UNCOMPRESSED_YCC(2), :EXIF_DATA_TYPE_COMPRESSED(3), :EXIF_DATA_TYPE_COUNT(4),
    :EXIF_DATA_TYPE_UNKNOWN(4));

enum ExifFormat is export (
  :EXIF_FORMAT_BYTE(1),
  :EXIF_FORMAT_ASCII(2),
  :EXIF_FORMAT_SHORT(3),
  :EXIF_FORMAT_LONG(4),
  :EXIF_FORMAT_RATIONAL(5),
  :EXIF_FORMAT_SBYTE(6),
  :EXIF_FORMAT_UNDEFINED(7),
  :EXIF_FORMAT_SSHORT(8),
  :EXIF_FORMAT_SLONG(9),
  :EXIF_FORMAT_SRATIONAL(10),
  :EXIF_FORMAT_FLOAT(11),
  :EXIF_FORMAT_DOUBLE(12),
);

enum ExifSupportLevel is export <EXIF_SUPPORT_LEVEL_UNKNOWN EXIF_SUPPORT_LEVEL_NOT_RECORDED
  EXIF_SUPPORT_LEVEL_MANDATORY EXIF_SUPPORT_LEVEL_OPTIONAL>;
enum ExifIfd is export (
  :EXIF_IFD_0(0),
  :EXIF_IFD_1(1),
  :EXIF_IFD_EXIF(2),
  :EXIF_IFD_GPS(3),
  :EXIF_IFD_INTEROPERABILITY(4),
  :EXIF_IFD_COUNT(5)
);
enum ExifByteOrder is export <EXIF_BYTE_ORDER_MOTOROLA EXIF_BYTE_ORDER_INTEL>;
enum ExifLogCode is export <EXIF_LOG_CODE_NONE EXIF_LOG_CODE_DEBUG EXIF_LOG_CODE_NO_MEMORY EXIF_LOG_CODE_CORRUPT_DATA>;
enum ExifDataOptiont is export (
  :EXIF_DATA_OPTION_IGNORE_UNKNOWN_TAGS(1),
  :EXIF_DATA_OPTION_FOLLOW_SPECIFICATION(2),
  :EXIF_DATA_OPTION_DONT_CHANGE_MAKER_NOTE(4)
);

constant EXIF_TAG_INTEROPERABILITY_INDEX         is export = 0x0001;
constant EXIF_TAG_INTEROPERABILITY_VERSION       is export = 0x0002;
constant EXIF_TAG_NEW_SUBFILE_TYPE               is export = 0x00fe;
constant EXIF_TAG_IMAGE_WIDTH                    is export = 0x0100;
constant EXIF_TAG_IMAGE_LENGTH                   is export = 0x0101;
constant EXIF_TAG_BITS_PER_SAMPLE                is export = 0x0102;
constant EXIF_TAG_COMPRESSION                    is export = 0x0103;
constant EXIF_TAG_PHOTOMETRIC_INTERPRETATION     is export = 0x0106;
constant EXIF_TAG_FILL_ORDER                     is export = 0x010a;
constant EXIF_TAG_DOCUMENT_NAME                  is export = 0x010d;
constant EXIF_TAG_IMAGE_DESCRIPTION              is export = 0x010e;
constant EXIF_TAG_MAKE                           is export = 0x010f;
constant EXIF_TAG_MODEL                          is export = 0x0110;
constant EXIF_TAG_STRIP_OFFSETS                  is export = 0x0111;
constant EXIF_TAG_ORIENTATION                    is export = 0x0112;
constant EXIF_TAG_SAMPLES_PER_PIXEL              is export = 0x0115;
constant EXIF_TAG_ROWS_PER_STRIP                 is export = 0x0116;
constant EXIF_TAG_STRIP_BYTE_COUNTS              is export = 0x0117;
constant EXIF_TAG_X_RESOLUTION                   is export = 0x011a;
constant EXIF_TAG_Y_RESOLUTION                   is export = 0x011b;
constant EXIF_TAG_PLANAR_CONFIGURATION           is export = 0x011c;
constant EXIF_TAG_RESOLUTION_UNIT                is export = 0x0128;
constant EXIF_TAG_TRANSFER_FUNCTION              is export = 0x012d;
constant EXIF_TAG_SOFTWARE                       is export = 0x0131;
constant EXIF_TAG_DATE_TIME                      is export = 0x0132;
constant EXIF_TAG_ARTIST                         is export = 0x013b;
constant EXIF_TAG_WHITE_POINT                    is export = 0x013e;
constant EXIF_TAG_PRIMARY_CHROMATICITIES         is export = 0x013f;
constant EXIF_TAG_SUB_IFDS                       is export = 0x014a;
constant EXIF_TAG_TRANSFER_RANGE                 is export = 0x0156;
constant EXIF_TAG_JPEG_PROC                      is export = 0x0200;
constant EXIF_TAG_JPEG_INTERCHANGE_FORMAT        is export = 0x0201;
constant EXIF_TAG_JPEG_INTERCHANGE_FORMAT_LENGTH is export = 0x0202;
constant EXIF_TAG_YCBCR_COEFFICIENTS             is export = 0x0211;
constant EXIF_TAG_YCBCR_SUB_SAMPLING             is export = 0x0212;
constant EXIF_TAG_YCBCR_POSITIONING              is export = 0x0213;
constant EXIF_TAG_REFERENCE_BLACK_WHITE          is export = 0x0214;
constant EXIF_TAG_XML_PACKET                     is export = 0x02bc;
constant EXIF_TAG_RELATED_IMAGE_FILE_FORMAT      is export = 0x1000;
constant EXIF_TAG_RELATED_IMAGE_WIDTH            is export = 0x1001;
constant EXIF_TAG_RELATED_IMAGE_LENGTH           is export = 0x1002;
constant EXIF_TAG_CFA_REPEAT_PATTERN_DIM         is export = 0x828d;
constant EXIF_TAG_CFA_PATTERN                    is export = 0x828e;
constant EXIF_TAG_BATTERY_LEVEL                  is export = 0x828f;
constant EXIF_TAG_COPYRIGHT                      is export = 0x8298;
constant EXIF_TAG_EXPOSURE_TIME                  is export = 0x829a;
constant EXIF_TAG_FNUMBER                        is export = 0x829d;
constant EXIF_TAG_IPTC_NAA                       is export = 0x83bb;
constant EXIF_TAG_IMAGE_RESOURCES                is export = 0x8649;
constant EXIF_TAG_EXIF_IFD_POINTER               is export = 0x8769;
constant EXIF_TAG_INTER_COLOR_PROFILE            is export = 0x8773;
constant EXIF_TAG_EXPOSURE_PROGRAM               is export = 0x8822;
constant EXIF_TAG_SPECTRAL_SENSITIVITY           is export = 0x8824;
constant EXIF_TAG_GPS_INFO_IFD_POINTER           is export = 0x8825;
constant EXIF_TAG_ISO_SPEED_RATINGS              is export = 0x8827;
constant EXIF_TAG_OECF                           is export = 0x8828;
constant EXIF_TAG_TIME_ZONE_OFFSET               is export = 0x882a;
constant EXIF_TAG_EXIF_VERSION                   is export = 0x9000;
constant EXIF_TAG_DATE_TIME_ORIGINAL             is export = 0x9003;
constant EXIF_TAG_DATE_TIME_DIGITIZED            is export = 0x9004;
constant EXIF_TAG_COMPONENTS_CONFIGURATION       is export = 0x9101;
constant EXIF_TAG_COMPRESSED_BITS_PER_PIXEL      is export = 0x9102;
constant EXIF_TAG_SHUTTER_SPEED_VALUE            is export = 0x9201;
constant EXIF_TAG_APERTURE_VALUE                 is export = 0x9202;
constant EXIF_TAG_BRIGHTNESS_VALUE               is export = 0x9203;
constant EXIF_TAG_EXPOSURE_BIAS_VALUE            is export = 0x9204;
constant EXIF_TAG_MAX_APERTURE_VALUE             is export = 0x9205;
constant EXIF_TAG_SUBJECT_DISTANCE               is export = 0x9206;
constant EXIF_TAG_METERING_MODE                  is export = 0x9207;
constant EXIF_TAG_LIGHT_SOURCE                   is export = 0x9208;
constant EXIF_TAG_FLASH                          is export = 0x9209;
constant EXIF_TAG_FOCAL_LENGTH                   is export = 0x920a;
constant EXIF_TAG_SUBJECT_AREA                   is export = 0x9214;
constant EXIF_TAG_TIFF_EP_STANDARD_ID            is export = 0x9216;
constant EXIF_TAG_MAKER_NOTE                     is export = 0x927c;
constant EXIF_TAG_USER_COMMENT                   is export = 0x9286;
constant EXIF_TAG_SUB_SEC_TIME                   is export = 0x9290;
constant EXIF_TAG_SUB_SEC_TIME_ORIGINAL          is export = 0x9291;
constant EXIF_TAG_SUB_SEC_TIME_DIGITIZED         is export = 0x9292;
constant EXIF_TAG_XP_TITLE                       is export = 0x9c9b;
constant EXIF_TAG_XP_COMMENT                     is export = 0x9c9c;
constant EXIF_TAG_XP_AUTHOR                      is export = 0x9c9d;
constant EXIF_TAG_XP_KEYWORDS                    is export = 0x9c9e;
constant EXIF_TAG_XP_SUBJECT                     is export = 0x9c9f;
constant EXIF_TAG_FLASH_PIX_VERSION              is export = 0xa000;
constant EXIF_TAG_COLOR_SPACE                    is export = 0xa001;
constant EXIF_TAG_PIXEL_X_DIMENSION              is export = 0xa002;
constant EXIF_TAG_PIXEL_Y_DIMENSION              is export = 0xa003;
constant EXIF_TAG_RELATED_SOUND_FILE             is export = 0xa004;
constant EXIF_TAG_INTEROPERABILITY_IFD_POINTER   is export = 0xa005;
constant EXIF_TAG_FLASH_ENERGY                   is export = 0xa20b;
constant EXIF_TAG_SPATIAL_FREQUENCY_RESPONSE     is export = 0xa20c;
constant EXIF_TAG_FOCAL_PLANE_X_RESOLUTION       is export = 0xa20e;
constant EXIF_TAG_FOCAL_PLANE_Y_RESOLUTION       is export = 0xa20f;
constant EXIF_TAG_FOCAL_PLANE_RESOLUTION_UNIT    is export = 0xa210;
constant EXIF_TAG_SUBJECT_LOCATION               is export = 0xa214;
constant EXIF_TAG_EXPOSURE_INDEX                 is export = 0xa215;
constant EXIF_TAG_SENSING_METHOD                 is export = 0xa217;
constant EXIF_TAG_FILE_SOURCE                    is export = 0xa300;
constant EXIF_TAG_SCENE_TYPE                     is export = 0xa301;
constant EXIF_TAG_NEW_CFA_PATTERN                is export = 0xa302;
constant EXIF_TAG_CUSTOM_RENDERED                is export = 0xa401;
constant EXIF_TAG_EXPOSURE_MODE                  is export = 0xa402;
constant EXIF_TAG_WHITE_BALANCE                  is export = 0xa403;
constant EXIF_TAG_DIGITAL_ZOOM_RATIO             is export = 0xa404;
constant EXIF_TAG_FOCAL_LENGTH_IN_35MM_FILM      is export = 0xa405;
constant EXIF_TAG_SCENE_CAPTURE_TYPE             is export = 0xa406;
constant EXIF_TAG_GAIN_CONTROL                   is export = 0xa407;
constant EXIF_TAG_CONTRAST                       is export = 0xa408;
constant EXIF_TAG_SATURATION                     is export = 0xa409;
constant EXIF_TAG_SHARPNESS                      is export = 0xa40a;
constant EXIF_TAG_DEVICE_SETTING_DESCRIPTION     is export = 0xa40b;
constant EXIF_TAG_SUBJECT_DISTANCE_RANGE         is export = 0xa40c;
constant EXIF_TAG_IMAGE_UNIQUE_ID                is export = 0xa420;
constant EXIF_TAG_GAMMA                          is export = 0xa500;
constant EXIF_TAG_PRINT_IMAGE_MATCHING           is export = 0xc4a5;
constant EXIF_TAG_PADDING                        is export = 0xea1c;
constant EXIF_TAG_GPS_VERSION_ID                 is export = 0x0000;
constant EXIF_TAG_GPS_LATITUDE_REF               is export = 0x0001; # INTEROPERABILITY_INDEX
constant EXIF_TAG_GPS_LATITUDE                   is export = 0x0002; # INTEROPERABILITY_VERSION
constant EXIF_TAG_GPS_LONGITUDE_REF              is export = 0x0003;
constant EXIF_TAG_GPS_LONGITUDE                  is export = 0x0004;
constant EXIF_TAG_GPS_ALTITUDE_REF               is export = 0x0005;
constant EXIF_TAG_GPS_ALTITUDE                   is export = 0x0006;
constant EXIF_TAG_GPS_TIME_STAMP                 is export = 0x0007;
constant EXIF_TAG_GPS_SATELLITES                 is export = 0x0008;
constant EXIF_TAG_GPS_STATUS                     is export = 0x0009;
constant EXIF_TAG_GPS_MEASURE_MODE               is export = 0x000a;
constant EXIF_TAG_GPS_DOP                        is export = 0x000b;
constant EXIF_TAG_GPS_SPEED_REF                  is export = 0x000c;
constant EXIF_TAG_GPS_SPEED                      is export = 0x000d;
constant EXIF_TAG_GPS_TRACK_REF                  is export = 0x000e;
constant EXIF_TAG_GPS_TRACK                      is export = 0x000f;
constant EXIF_TAG_GPS_IMG_DIRECTION_REF          is export = 0x0010;
constant EXIF_TAG_GPS_IMG_DIRECTION              is export = 0x0011;
constant EXIF_TAG_GPS_MAP_DATUM                  is export = 0x0012;
constant EXIF_TAG_GPS_DEST_LATITUDE_REF          is export = 0x0013;
constant EXIF_TAG_GPS_DEST_LATITUDE              is export = 0x0014;
constant EXIF_TAG_GPS_DEST_LONGITUDE_REF         is export = 0x0015;
constant EXIF_TAG_GPS_DEST_LONGITUDE             is export = 0x0016;
constant EXIF_TAG_GPS_DEST_BEARING_REF           is export = 0x0017;
constant EXIF_TAG_GPS_DEST_BEARING               is export = 0x0018;
constant EXIF_TAG_GPS_DEST_DISTANCE_REF          is export = 0x0019;
constant EXIF_TAG_GPS_DEST_DISTANCE              is export = 0x001a;
constant EXIF_TAG_GPS_PROCESSING_METHOD          is export = 0x001b;
constant EXIF_TAG_GPS_AREA_INFORMATION           is export = 0x001c;
constant EXIF_TAG_GPS_DATE_STAMP                 is export = 0x001d;
constant EXIF_TAG_GPS_DIFFERENTIAL               is export = 0x001e;

=begin pod

=head1 NAME

Image::Libexif::Constants - Libexif-related constants

=head1 SYNOPSIS
=begin code

use v6;

use Image::Libexif::Constants;

=end code

=head1 DESCRIPTION

For more details on libexif see L<https://github.com/libexif> and L<https://libexif.github.io/docs.html>.

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
