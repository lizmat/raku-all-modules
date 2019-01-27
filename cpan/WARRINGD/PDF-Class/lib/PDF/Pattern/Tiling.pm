use v6;

use PDF::COS::Stream;
use PDF::Pattern;
use PDF::Content::XObject;
use PDF::Content::Graphics;
use PDF::Content::Resourced;

#| /PatternType 1 - Tiling

class PDF::Pattern::Tiling
    is PDF::COS::Stream
    does PDF::Pattern
    does PDF::Content::XObject['Form']
    does PDF::Content::Graphics
    does PDF::Content::Resourced {

    use PDF::COS::Tie;
    use PDF::Resources;

    # see [PDF 32000 Table 75 - Additional Entries Specific to a Type 1 Pattern Dictionary]
    ## use ISO_32000::Type_1_Pattern;
    ## also does ISO_32000::Type_1_Pattern;

    subset PaintCode of Int where 1|2;
    has PaintCode $.PaintType is entry(:required);   # (Required) A code that determines how the color of the pattern cell is to be specified:
                                                     #  1: Colored tiling pattern.
                                                     #  2: Uncolored tiling pattern.
    subset TilingCode of Int where 1|2|3;
    has TilingCode $.TilingType is entry(:required); # (Required) A code that controls adjustments to the spacing of tiles relative to the device pixel grid:
                                                     #  1: Constant spacing.
                                                     #  2: No distortion.
                                                     #  3: Constant spacing and faster tiling.
    has Numeric @.BBox is entry(:required,:len(4));  # (Required) An array of four numbers in the pattern coordinate system giving the coordinates of the left, bottom, right, and top edges, respectively, of the pattern cell’s bounding box. These boundaries are used to clip the pattern cell.
    has Numeric $.XStep is entry(:required);         # (Required) The desired horizontal spacing between pattern cells, measured in the pattern coordinate system.
    has Numeric $.YStep is entry(:required);         # (Required) The desired vertical spacing between pattern cells, measured in the pattern coordinate system.
    has PDF::Resources $.Resources is entry(:required);        # (Required) A resource dictionary containing all of the named resources required by the pattern’s content stream.
}
