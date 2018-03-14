use v6;

use PDF::COS::Tie::Hash;

#| OutlineItem - an entry in the Outlines Dictionary
#| See /First and /Last Accessors in the PDF::Outlines

role PDF::OutlineItem
    does PDF::COS::Tie::Hash {

    use PDF::COS::Tie;

    has Str $.Title is entry(:required);              #| (Required) The text to be displayed on the screen for this item.
    has Hash $.Parent is entry(:required, :indirect); #| (Required; must be an indirect reference) The parent of this item in the outline hierarchy. The parent of a top-level item is the outline dictionary itself.
    has PDF::OutlineItem $.Prev is entry(:indirect);       #| (Required for all but the first item at each level; must be an indirect reference)The previous item at this outline level.
    has PDF::OutlineItem $.Next is entry(:indirect);       #| (Required for all but the last item at each level; must be an indirect reference)The next item at this outline level.
    has PDF::OutlineItem $.First is entry(:indirect);      #| (Required if the item has any descendants; must be an indirect reference) The first of this item’s immediate children in the outline hierarchy.
    has PDF::OutlineItem $.Last is entry(:indirect);       #| (Required if the item has any descendants; must be an indirect reference) The last of this item’s immediate children in the outline hierarchy.
    has UInt $.Count is entry;                        #| (Required if the item has any descendants) If the item is open, the total number of its open descendants at all lower levels of the outline hierarchy. If the item is closed, a negative integer whose absolute value specifies how many descendants would appear if the item were reopened.
    has $.Dest is entry;                              #| (Optional; not permitted if an A entry is present) The destination to be displayed when this item is activated
    use PDF::Action;
    has PDF::Action $.A is entry(:alias<action>);          #| (Optional; PDF 1.1; not permitted if a Dest entry is present) The action to be performed when this item is activate
    has Hash $.SE is entry(:indirect, :alias<structure-element>);                #| (Optional; PDF 1.3; must be an indirect reference) The structure element to which the item refers.
    #| Note: The ability to associate an outline item with a structure element (such as the beginning of a chapter) is a PDF 1.3 feature. For backward compatibility with earlier PDF versions, such an item should also specify a destination (Dest) corresponding to an area of a page where the contents of the designated structure element are displayed.
    has Numeric @.C is entry(:len(3), :alias<color>);                #| (Optional; PDF 1.4) An array of three numbers in the range 0.0 to 1.0, representing the components in the DeviceRGB color space of the color to be used for the outline entry’s text. Default value: [ 0.0 0.0 0.0 ].
    my enum OutlineFlag is export(:OutlineFlag) « :Italic(1) :Bold(2) »;
    has UInt $.F is entry(:alias<flags>);                            #| (Optional; PDF 1.4) A set of flags specifying style characteristics for displaying the outline item’s text. Default value: 0.

}
