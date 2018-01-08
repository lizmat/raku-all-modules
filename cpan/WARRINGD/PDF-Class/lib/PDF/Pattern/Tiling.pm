use v6;

use PDF::DAO::Stream;
use PDF::Pattern;

#| /ShadingType 1 - Tiling

class PDF::Pattern::Tiling
    is PDF::DAO::Stream
    does PDF::Pattern {

    use PDF::DAO::Tie;

    # see [PDF 1.7 TABLE 4.25 Additional entries specific to a type 1 pattern dictionary]
    subset PaintCode of Int where 1|2;
    has PaintCode $.PaintType is entry(:required);   #| (Required) A code that determines how the color of the pattern cell is to be specified:
                                                     #|  1: Colored tiling pattern.
                                                     #|  2: Uncolored tiling pattern.
    subset TilingCode of Int where 1|2|3;
    has TilingCode $.TilingType is entry(:required); #| (Required) A code that controls adjustments to the spacing of tiles relative to the device pixel grid:
                                                     #|  1: Constant spacing.
                                                     #|  2: No distortion.
                                                     #|  3: Constant spacing and faster tiling.
    has Numeric @.BBox is entry(:required,:len(4));  #| (Required) An array of four numbers in the pattern coordinate system giving the coordinates of the left, bottom, right, and top edges, respectively, of the pattern cell’s bounding box. These boundaries are used to clip the pattern cell.
    has Numeric $.XStep is entry(:required);         #| (Required) The desired horizontal spacing between pattern cells, measured in the pattern coordinate system.
    has Numeric $.YStep is entry(:required);         #| (Required) The desired vertical spacing between pattern cells, measured in the pattern coordinate system.
    use PDF::Resources;
    has PDF::Resources $.Resources is entry(:required);        #| (Required) A resource dictionary containing all of the named resources required by the pattern’s content stream (see Section 3.7.2, “Resource Dictionaries”).
}
