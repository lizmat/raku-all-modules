use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::ICCBased
    is PDF::ColorSpace {

    use PDF::COS::Name;
    use PDF::COS::Stream;
    use PDF::COS::Tie;

    # see [PDF 1.7 TABLE 4.16 Additional entries specific to an ICC profile stream dictionary]
    role ICCDict
	does PDF::COS::Tie::Hash {
        has UInt $.N is entry(:required);          #| (Required) The number of color components in the color space described by the ICC profile data. This number must match the number of components actually in the ICC profile. As of PDF 1.4, N must be 1, 3, or 4.
	my subset ArrayOrName of PDF::COS where Array | PDF::COS::Name;
	has ArrayOrName $.Alternate is entry;      #| (Optional) An alternate color space to be used in case the one specified in the stream data is not supported (for example, by applications designed for earlier versions of PDF). The alternate space may be any valid color space (except a Pattern color space) that has the number of components specified by N. If this entry is omitted and the application does not understand the ICC profile data, the color space used is DeviceGray, DeviceRGB, or DeviceCMYK, depending on whether the value of N is 1, 3, or 4, respectively.
       #| Note: There is no conversion of source color values, such as a tint transformation, when using the alternate color space. Color values within the range of the ICCBased color space might not be within the range of the alternate color space. In this case, the nearest values within the range of the alternate space are substituted.

	has Numeric @.Range is entry;              #| (Optional) An array of 2 × N numbers [ min0 max0 min1 max1 … ] specifying the minimum and maximum valid values of the corresponding color components. These values must match the information in the ICC profile. Default value: [ 0.0 1.0 0.0 1.0 … ].

        has PDF::COS::Stream $.Metadata is entry;  #| (Optional; PDF 1.4) A metadata stream containing metadata for the color space
    }

    has ICCDict $.dict is index(1);
    method N         is rw { self.dict.N }
    method Alternate is rw { self.dict.Alternate }
    method Range     is rw { self.dict.Range }
    method Metadata  is rw { self.dict.Metadata }

}
