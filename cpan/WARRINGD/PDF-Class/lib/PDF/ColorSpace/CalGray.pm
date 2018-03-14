use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::CalGray
    is PDF::ColorSpace {

    use PDF::COS::Tie;
    use PDF::COS::Tie::Hash;

    # see [PDF 1.7 TABLE 4.13 Entries in a CalGray color space dictionary]
    role CalGrayDict
	does PDF::COS::Tie::Hash {
	has Numeric @.WhitePoint is entry(:len(3), :required); #| (Required) An array of three numbers [ XW YW ZW ] specifying the tristimulus value, in the CIE 1931 XYZ space, of the diffuse white point; see “CalRGB Color Spaces,” below, for further discussion. The numbers XW and ZW must be positive, and YW must be equal to 1.0.
	has Numeric @.BlackPoint is entry(:len(3));            #| (Optional) An array of three numbers [ XB YB ZB ] specifying the tristimulus value, in the CIE 1931 XYZ space, of the diffuse black point; see “CalRGB Color Spaces,” below, for further discussion. All three of these numbers must be non-negative. Default value: [ 0.0 0.0 0.0 ].
	has Numeric $.Gamma is entry;                          #| (Optional) A number G defining the gamma for the gray (A) component. Gmust be positive and is generally greater than or equal to 1. Default value: 1.
    }

    has CalGrayDict $.dict is index(1);

    method WhitePoint is rw { self.dict.WhitePoint }
    method BlackPoint is rw { self.dict.BlackPoint }
    method Gamma      is rw { self.dict.Gamma }
}
