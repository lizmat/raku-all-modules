use v6;

use PDF::XObject;
use PDF::Content::XObject;
use PDF::Content::Image;

#| XObjects
#| /Type XObject /Subtype /Image
#| See [PDF 1.7 Section 4.8 - Images ]
class PDF::XObject::Image
    is PDF::XObject
    is PDF::Content::Image
    does PDF::Content::XObject['Image'] {

    use PDF::COS::Tie;
    use PDF::COS::Stream;
    use PDF::COS::Array;
    use PDF::COS::Name;

    # See [PDF 1.7 TABLE 4.39 Additional entries specific to an image dictionary]
    has Numeric $.Width is entry(:required);      #| (Required) The width of the image, in samples.
    has Numeric $.Height is entry(:required);     #| (Required) The height of the image, in samples.
    use PDF::ColorSpace;
    my subset NameOrColorSpace of PDF::COS where PDF::COS::Name | PDF::ColorSpace;
    has NameOrColorSpace $.ColorSpace is entry;   #| (Required for images, except those that use the JPXDecode filter; not allowed for image masks) The color space in which image samples are specified; it can be any type of color space except Pattern.
    has UInt $.BitsPerComponent is entry;         #| (Required except for image masks and images that use the JPXDecode filter)The number of bits used to represent each color component.
    has PDF::COS::Name $.Intent is entry;         #| (Optional; PDF 1.1) The name of a color rendering intent to be used in rendering the image
    has Bool $.ImageMask is entry;                #| (Optional) A flag indicating whether the image is to be treated as an image mask. If this flag is true, the value of BitsPerComponent must be 1 and Mask and ColorSpace should not be specified;
    subset StreamOrArray of PDF::COS where PDF::COS::Stream | PDF::COS::Array;
    has StreamOrArray $.Mask is entry;            #| (Optional) A flag indicating whether the image is to be treated as an image mask (see Section 4.8.5, “Masked Images”). If this flag is true, the value of BitsPerComponent must be 1 and Mask and ColorSpace should not be specified;
    has Numeric @.Decode is entry;                #| (Optional) An array of numbers describing how to map image samples into the range of values appropriate for the image’s color space
    has Bool $.Interpolate is entry;              #| (Optional) A flag indicating whether image interpolation is to be performed
    has Hash @.Alternatives is entry;             #| An array of alternate image dictionaries for this image
    has PDF::XObject::Image $.SMask is entry;     #| (Optional; PDF 1.4) A subsidiary image XObject defining a soft-mask image
    subset SMaskInInt of Int where 0|1|2;
    has SMaskInInt $.SMaskInData is entry;        #| (Optional for images that use the JPXDecode filter, meaningless otherwise; A code specifying how soft-mask information encoded with image samples should be used:
                                                  #| 0: If present, encoded soft-mask image information should be ignored.
                                                  #| 1: The image’s data stream includes encoded soft-mask values. An application can create a soft-mask image from the information to be used as a source of mask shape or mask opacity in the transparency imaging model.
                                                  #| 2: The image’s data stream includes color channels that have been preblended with a background; the image data also includes an opacity channel. An application can create a soft-mask image with a Matte entry from the opacity channel information to be used as a source of mask shape or mask opacity in the transparency model.
                                                  #| If this entry has a nonzero value, SMask should not be specified
    has PDF::COS::Name $.Name is entry;           #| (Required in PDF 1.0; optional otherwise) The name by which this image XObject is referenced in the XObject subdictionary of the current resource dictionary.
                                                  #| Note: This entry is obsolescent and its use is no longer recommended. (See implementation note 53 in Appendix H.)
    has UInt $.StructParent is entry;             #| (Required if the image is a structural content item; PDF 1.3) The integer key of the image’s entry in the structural parent tree
    has Str $.ID is entry;                        #| (Optional; PDF 1.3; indirect reference preferred) The digital identifier of the image’s parent Web Capture content set
    has Hash $.OPI is entry;                      #| (Optional; PDF 1.2) An OPI version dictionary for the image. If ImageMask is true, this entry is ignored.
    has PDF::COS::Stream $.Metadata is entry;     #| (Optional; PDF 1.4) A metadata stream containing metadata for the image
    has Hash $.OC is entry;                       #| (Optional; PDF 1.5) An optional content group or optional content membership dictionary

    my subset PNGPredictor of Int where 10 .. 15;

    method to-png {
        use PDF::Content::Image::PNG :PNG-CS;
        need PDF::ColorSpace::Indexed;
        need PDF::IO::Filter;
        my $bit-depth = self.BitsPerComponent || 8;
        my UInt $width = self.Width;
        my UInt $height = self.Height;
        my PDF::Content::Image::PNG::Header $hdr .= new: :$width, :$height, :$bit-depth;
        my Blob $stream;
        my Blob $palette;
        my Blob $trans;

        my $decode-parms = .[0] with self.DecodeParms;
        if $decode-parms
            && self.Filter ~~ 'FlateDecode'
            && $decode-parms<Predictor> ~~ PNGPredictor {
            # looks like a PNG image

            given self.ColorSpace {
                when PDF::ColorSpace::Indexed {
                    $hdr.color-type = PNG-CS::RGB-Palette;
                    my Str $data = .isa(PDF::COS::Stream) ?? .encoded !! $_
                        with .Lookup;
                    $palette = buf8.new: .encode("latin-1") with $data;
                    with self.SMask {
                        $trans = .stream
                            with self.to-dict: $_;
                    }
                }
                when 'DeviceRGB'|'DeviceGray' {
                    $hdr.color-type = $_ ~~ 'DeviceRGB'
                        ?? PNG-CS::RGB !! PNG-CS::Gray;
                    my \colors =  $hdr.color-type == RGB
                        ?? 3 !! 1;
                    if $bit-depth == 8|16  {
                        # SMask contains alpha channel - merge it
                        with self.SMask {
                            my Blob $alpha-channel = .decoded;
                            my Blob $color-channel = self.decoded;
                            my uint $na = $bit-depth div 8;
                            my uint $nc = colors * $na;
                            my uint $len = +$alpha-channel;;
                            my uint $a = 0;
                            my uint $c = 0;
                            my $i = 0;
                            my $decoded = buf8.allocate: $len * (colors + 1);
                            while $a < $len {
                                $decoded[$i++] = $color-channel[$c++]
                                    for 1 .. $nc;
                                $decoded[$i++] = $alpha-channel[$a++]
                                    for 1 .. $na;
                            }
                            $hdr.color-type = $hdr.color-type == PNG-CS::RGB
                                ?? PNG-CS::RGB-Alpha !! PNG-CS::Gray-Alpha;
                            my %dict = %(self.list);
                            %dict<DecodeParms> = %(self<DecodeParms>.list);
                            %dict<DecodeParms><Colors>++;
                            $stream = buf8.new: PDF::IO::Filter.encode( $decoded, :%dict );
                        }
                    }
                }
                default {
                     X::NYI.new(:feature("PNG Image with color-space: {.perl}")).throw;
                }
            }

            $stream //= self.encoded.encode: "latin-1";
        }
        else {
            X::NYI.new(:feature("PNG Image Conversion")).throw;
            my $Colors = $hdr.color-type == PNG-CS::RGB ?? 3 !! 1;
            my %dict = %(
                :Filter<FlateDecode>,
                :DecodeParms{
                    :Predictor(10),
                    :Width($width),
                    :Height($height),
                    :$Colors,
                    :BitsPerComponent($bit-depth),
                },
            );
            $stream = buf8.new: PDF::IO::Filter.encode(
                self.decoded, :%dict,
            );
        }

        my PDF::Content::Image::PNG $png .= new: :$hdr, :$stream;
        $png.palette = $_ with $palette;
        $png.trans = $_ with $trans;
        $png;
    }

}
