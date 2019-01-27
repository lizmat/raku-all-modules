use v6;

use PDF::ColorSpace;

class PDF::ColorSpace::CalRGB
    is PDF::ColorSpace {

   use PDF::COS::Tie;
   use PDF::COS::Tie::Hash;

   role CalRGBDict
       does PDF::COS::Tie::Hash {

       # see [PDF 32000 Table 64 - Entries in a CalRGB Colour Space Dictionary]
       ## use ISO_32000::CalRGB_colour_space;
       ## also does ISO_32000::CalRGB_colour_space;

       has Numeric @.WhitePoint is entry(:required, :len(3), :default[1.0, 1.0, 1.0]);    # (Required) An array of three numbers [ XW YW ZW ] specifying the tristimulus value, in the CIE 1931 XYZ space, of the diffuse white point; see below for further discussion. The numbers XW and ZW are positive, and YW is equal to 1.0.

       has Numeric @.BlackPoint is entry(:len(3), :default[0.0, 0.0, 0.0]);    # (Optional) An array of three numbers [ XB YB ZB ] specifying the tristimulus value, in the CIE 1931 XYZ space, of the diffuse black point; see below for further discussion. All three of these numbers must be non-negative. Default value: [ 0.0 0.0 0.0 ].

       has Numeric @.Gamma is entry(:len(3), :default[1.0, 1.0, 1.0]);         # (Optional) An array of three numbers [ GR GG GB ] specifying the gamma for the red, green, and blue (A, B, and C) components of the color space. Default value: [ 1.0 1.0 1.0 ].

       has Numeric @.Matrix is entry(:len(9), :default[1,0,0,0,1,0,0,0,1]);    # (Optional) An array of nine numbers [ XA YA ZA XB YB ZB XC YC ZC ] specifying the linear interpretation of the decoded A, B, and C components of the color space with respect to the final XYZ representation. Default value: the identity matrix [ 1 0 0 0 1 0 0 0 1 ].
   }

   has CalRGBDict $.dict is index(1);
   method props is rw handles <WhitePoint BlackPoint Gamma Matrix> { $.dict; }
}
