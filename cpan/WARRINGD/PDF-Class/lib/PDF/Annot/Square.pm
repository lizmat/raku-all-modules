use v6;

use PDF::Annot::Markup;

class PDF::Annot::Square
    is PDF::Annot::Markup {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::Border;

    # See [PDF 32000 Table 177 - Additional entries specific to a widget annotation]
    ## use ISO_32000::Square_or_circle_annotation_additional;
    ## also does ISO_32000::Square_or_circle_annotation_additional;
    has PDF::Border $.BS is entry(:alias<border-style>);       # (Optional) A border style dictionary specifying the line width and dash pattern to be used in drawing the rectangle or ellipse.
                                         # Note: The annotation dictionary’s AP entry, if present, takes precedence over the Land BS entries

    has Numeric @.IC is entry(:alias<interior-color>);           # (Optional; PDF 1.4) An array of numbers in the range 0.0 to 1.0 specifying the interior color with which to fill the annotation’s rectangle or ellipse. The number of array elements determines the color space in which the color is defined:
    # 0: No color; transparent
    # 1: DeviceGray
    # 3: 3DeviceRGB
    # 4: DeviceCMYK

    has Hash $.BE is entry(:alias<border-effect>);              # (Optional; PDF 1.5) A border effect dictionary describing an effect applied to the border described by the BS entry

    has Numeric @.RD is entry(:len(4), :alias<rectangle-differences>);  # (Optional; PDF 1.5) A set of four numbers describing the numerical differences between two rectangles: the Rect entry of the annotation and the actual boundaries of the underlying square or circle. Such a difference can occur in situations where a border effect (described by BE) causes the size of the Rect to increase beyond that of the square or circle.
    # The four numbers correspond to the differences in default user space between the left, top, right, and bottom coordinates of Rect and those of the square or circle, respectively. Each value must be greater than or equal to 0. The sum of the top and bottom differences must be less than the height of Rect, and the sum of the left and right differences must be less than the width of Rect.

}
