use v6;

use PDF::COS::Tie::Hash;
use PDF::Class::Type;
use PDF::Page;

#| /Type /Annot Annotations
class PDF::Annot
    is PDF::COS::Dict
    does PDF::Class::Type {

    use PDF::COS::Tie;
    use PDF::COS::Tie::Array;
    use PDF::COS::Name;
    use PDF::COS::DateString;
    use PDF::COS::TextString;
    use PDF::Appearance;
    use PDF::Border;
    use PDF::OCG;   # optional content group
    use PDF::OCMD;  # optional content membership dict
    my subset OCG-or-OCMD where PDF::OCG|PDF::OCMD;

    # See [PDF 32000 Table 164 - Entries common to all annotation dictionaries]
    ## use ISO_32000::Annotation_common;
    ## also does ISO_32000::Annotation_common;

    method cb-init {
        use PDF::Field :coerce, :FieldLike;
        # annots are also sometimes fields
        coerce(self, PDF::Field)
            if self ~~ FieldLike && self !~~ PDF::Field;
    }

    has PDF::COS::Name $.FT is entry(:inherit, :alias<field-type>); # Include this, just to help discover if we're a field

    # See [PDF Spec 1.7 table 8.15 - Entries common to all annotation dictionaries ]
    has PDF::COS::Name $.Type is entry(:alias<type>) where 'Annot';
    my subset AnnotName of PDF::COS::Name where 'Text'|'Link'|'FreeText'|'Line'|'Square'|
        'Circle'|'Polygon'|'PolyLine'|'Highlight'|'Underline'|'Squiggly'|'StrikeOut'|
        'Stamp'|'Caret'|'Ink'|'Popup'|'FileAttachment'|'Sound'|'Movie'|'Widget'|'Screen'|
        'PrinterMark'|'TrapNet'|'Watermark'|'3D'|'Redact';
    has AnnotName $.Subtype is entry(:required, :alias<subtype>);
    has Numeric @.Rect is entry(:required, :len(4), :alias<rect>);            # (Required) The annotation rectangle, defining the location of the annotation on the page in default user space units.
    has PDF::COS::TextString $.Contents is entry(:alias<content>);               # (Optional) Text to be displayed for the annotation or, if this type of annotation does not display text, an alternate description of the annotation’s contents in human-readable form
    has PDF::Page $.P is entry(:alias<page>);                   # (Optional; PDF 1.3; not used in FDF files) An indirect reference to the page object with which this annotation is associated.
    has PDF::COS::TextString $.NM is entry(:alias<annotation-name>);       # (Optional; PDF 1.4) The annotation name, a text string uniquely identifying it among all the annotations on its page.
    my subset DateOrTextString where PDF::COS::DateString | PDF::COS::TextString;
    sub coerce-mod-time(Str $s is rw, DateOrTextString) {
	my \target-type = $s ~~ PDF::COS::DateString::DateRegex
	    ?? PDF::COS::DateString
	    !! PDF::COS::TextString;
	PDF::COS.coerce($s, target-type);
    }
    has DateOrTextString $.M is entry(:coerce(&coerce-mod-time), :alias<mod-time>);                # (Optional; PDF 1.1) The date and time when the annotation was most recently modified.
                                                                # The preferred format is a date string, but viewer applications should be prepared to accept and display a string in any format.
##    my UInt enum AnnotsFlag is export(:AnnotsFlag) « :Invisable(1) :Hidden(2) :Print(3) :NoZoom(4) :NoRotate(5) :NoView(6) :ReadOnly(7) :Locked(8) :ToggleNoView(9) :LockedContents(10) »;
    my subset AnnotFlagsInt of UInt where 0 ..^ 2 +< 9;
    has AnnotFlagsInt $.F is entry(:alias<flags>);              # (Optional; PDF 1.1) A set of flags specifying various characteristics of the annotation
    has PDF::Appearance $.AP is entry(:alias<appearance>);      # (Optional; PDF 1.2) An appearance dictionary specifying how the annotation is presented visually on the page
    has PDF::COS::Name $.AS is entry(:alias<appearance-state>); # (Required if the appearance dictionary AP contains one or more subdictionaries; PDF 1.2) The annotation’s appearance state, which selects the applicable appearance stream from an appearance subdictionary
    role Border does PDF::COS::Tie::Array {
        has Numeric $.horizontal-radius is index(0, :required);
        has Numeric $.vertical-radius is index(1, :required);
        has Numeric $.width is index(2, :required);
        has Numeric @.dash-pattern is index(3);
    }
    has Border $.Border is entry(:default[0, 0, 1]);                     # (Optional) An array specifying the characteristics of the annotation’s border. The border is specified as a rounded rectangle.
    has Numeric @.C is entry(:alias<color>);                    # (Optional; PDF 1.1) An array of numbers in the range 0.0 to 1.0, representing a color used for (*) background, when closed, (*) title bar of pop-up window, (*) link border
    has UInt $.StructParent is entry;                           # (Required if the annotation is a structural content item; PDF 1.3) The integer key of the annotation’s entry in the structural parent tree
    has OCG-or-OCMD $.OC is entry(:alias<optional-content>);       # (Optional; PDF 1.5) An optional content group or optional content membership dictionary specifying the optional content properties for the annotation.

    has Hash $.DR is entry(:alias<default-resources>);          # In PDF 1.2, an additional entry in the field dictionary, DR, was defined but was never implemented. Beginning with PDF 1.5, this entry is obsolete and should be ignored.

}
