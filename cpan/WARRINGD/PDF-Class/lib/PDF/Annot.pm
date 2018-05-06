use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

#| /Type /Annot Annotations
#| See [PDF 1.7 Section 8.4.1 - Annotation Dictionaries ]
class PDF::Annot
    is PDF::COS::Dict
    does PDF::Class::Type {

    use PDF::COS::Tie;
    use PDF::COS::Name;
    use PDF::COS::DateString;
    use PDF::COS::TextString;

    # See [PDF Spec 1.7 table 8.15 - Entries common to all annotation dictionaries ]
    has PDF::COS::Name $.Type is entry where 'Annot';
    has PDF::COS::Name $.Subtype is entry(:required);
    has Numeric @.Rect is entry(:required);                     #| (Required) The annotation rectangle, defining the location of the annotation on the page in default user space units.
    has PDF::COS::TextString $.Contents is entry;               #| (Optional) Text to be displayed for the annotation or, if this type of annotation does not display text, an alternate description of the annotation’s contents in human-readable form
    has Hash $.P is entry(:alias<page>);                        #| (Optional; PDF 1.3; not used in FDF files) An indirect reference to the page object with which this annotation is associated.
    has PDF::COS::TextString $.NM is entry(:alias<name>);       #| (Optional; PDF 1.4) The annotation name, a text string uniquely identifying it among all the annotations on its page.
    subset DateOrTextString where PDF::COS::DateString | PDF::COS::TextString;
    multi sub coerce(Str $s is rw, DateOrTextString) {
	my $target-type = $s ~~ /^ 'D:'? $<year>=\d**4/
	    ?? PDF::COS::DateString
	    !! PDF::COS::TextString;
	PDF::COS.coerce($s, $target-type);
    }
    has DateOrTextString $.M is entry(:&coerce, :alias<mod-time>);                #| (Optional; PDF 1.1) The date and time when the annotation was most recently modified.
                                                                #| The preferred format is a date string, but viewer applications should be prepared to accept and display a string in any format.
    subset AnnotFlagsInt of UInt where 0 ..^ 2 +< 9;
##    my UInt enum AnnotsFlag is export(:AnnotsFlag) « :Invisable(1) :Hidden(2) :Print(3) :NoZoom(4) :NoRotate(5) :NoView(6)
##						     :ReadOnly(7) :Locked(8) :ToggleNoView(9) :LockedContents(10) »;
    has AnnotFlagsInt $.F is entry(:alias<flags>);              #| (Optional; PDF 1.1) A set of flags specifying various characteristics of the annotation
    use PDF::Appearance;
    has PDF::Appearance $.AP is entry(:alias<appearance>);      #| (Optional; PDF 1.2) An appearance dictionary specifying how the annotation is presented visually on the page
    has PDF::COS::Name $.AS is entry(:alias<appearance-state>); #| (Required if the appearance dictionary AP contains one or more subdictionaries; PDF 1.2) The annotation’s appearance state, which selects the applicable appearance stream from an appearance subdictionary
    has Numeric @.Border is entry;                              #| (Optional) An array specifying the characteristics of the annotation’s border. The border is specified as a rounded rectangle.
    has Numeric @.C is entry(:alias<color>);                    #| (Optional; PDF 1.1) An array of numbers in the range 0.0 to 1.0, representing a color used for (*) background, when closed, (*) title bar of pop-up window, (*) link border
    has UInt $.StructParent is entry;                           #| (Required if the annotation is a structural content item; PDF 1.3) The integer key of the annotation’s entry in the structural parent tree
    has Hash $.OC is entry(:alias<optional-content>);           #| (Optional; PDF 1.5) An optional content group or optional content membership dictionary (see Section 4.10, “Optional Content”) specifying the optional content properties for the annotation.

    # See [PDF 1.7 Section 8.6.2, “Field Dictionaries” (Variable Text)]
    has Hash $.DR is entry(:alias<default-resources>);                 #| In PDF 1.2, an additional entry in the field dictionary, DR, was defined but was never implemented. Beginning with PDF 1.5, this entry is obsolete and should be ignored.

}
