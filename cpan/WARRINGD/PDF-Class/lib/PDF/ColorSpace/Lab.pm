use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::Lab
    is PDF::ColorSpace {

    use PDF::COS::Tie;
    use PDF::COS::Tie::Hash;
    # see [PDF 1.7 TABLE 4.15 Entries in a Lab color space dictionary]
    role LabDict
	does PDF::COS::Tie::Hash {
	has Numeric @.WhitePoint is entry(:len(3), :required); #| (Required) An array of three numbers [ XW YW ZW ] specifying the tristimulus value, in the CIE 1931 XYZ space, of the diffuse white point; see “CalRGB Color Spaces” on page 247 for further discussion. The numbers XW and ZW must be positive, and YWmust be equal to 1.0.
	has Numeric @.BlackPoint is entry(:len(3));            #| the CIE 1931 XYZ space, of the diffuse black point; see “CalRGB Color Spaces” on page 247 for further discussion. All three of these numbers must be non-negative. Default value: [ 0.0 0.0 0.0 ].
	has Numeric @.Range is entry(:len(4));                  #| (Optional) An array of four numbers [ amin amax bmin bmax ] specifying the range of valid values for the a* and b* (B and C) components of the color. Component values falling outside the specified range are adjusted to the nearest valid value without error indication. Default value: [ −100 100 −100 100 ].
    }

    has LabDict $.dict is index(1);
    method WhitePoint is rw { self.dict.WhitePoint }
    method BlackPoint is rw { self.dict.BlackPoint }
    method Range      is rw { self.dict.Range }

}
