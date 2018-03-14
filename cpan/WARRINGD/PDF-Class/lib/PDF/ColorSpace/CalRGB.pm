use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::CalRGB
    is PDF::ColorSpace {

   use PDF::COS::Tie;
   use PDF::COS::Tie::Hash;

   # see [PDF 1.7 TABLE 4.14 Entries in a CalRGB color space dictionary]
   role CalRGBDict
       does PDF::COS::Tie::Hash {
       has Numeric @.WhitePoint is entry(:len(3), :required);  #| (Required) An array of three numbers [ XW YW ZW ] specifying the tristimulus value, in the CIE 1931 XYZ space, of the diffuse white point; see below for further discussion. The numbers XW and ZW must be positive, and YW must be equal to 1.0.
       has Numeric @.BlackPoint is entry(:len(3));             #| (Optional) An array of three numbers [ XB YB ZB ] specifying the tristimulus value, in the CIE 1931 XYZ space, of the diffuse black point; see below for further discussion. All three of these numbers must be non-negative. Default value: [ 0.0 0.0 0.0 ].
       has Numeric @.Gamma is entry(:len(3));                  #| (Optional) An array of three numbers [ GR GG GB ] specifying the gamma for the red, green, and blue (A, B, and C) components of the color space. Default value: [ 1.0 1.0 1.0 ].
       has Numeric @.Matrix is entry(:len(9));                 #| (Optional) An array of nine numbers [ XA YA ZA XB YB ZB XC YC ZC ] specifying the linear interpretation of the decoded A, B, and C components of the color space with respect to the final XYZ representation. Default value: the identity matrix [ 1 0 0 0 1 0 0 0 1 ].
   }

   has CalRGBDict $.dict is index(1);
 
   method WhitePoint is rw { self.dict.WhitePoint }
   method BlackPoint is rw { self.dict.BlackPoint }
   method Gamma      is rw { self.dict.Gamma }
   method Matrix     is rw { self.dict.Matrix }
}
