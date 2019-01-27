use v6;

use PDF::XObject;
use PDF::Content::XObject;
use PDF::Content::Resourced;
use PDF::Content::Graphics;

#| XObject Forms - /Type /XObject /Subtype Form
class PDF::XObject::Form
    is PDF::XObject
    does PDF::Content::XObject['Form']
    does PDF::Content::Graphics
    does PDF::Content::Resourced {

    # See [PDF Spec 32000 Table 95 - Additional Entries Specific to a Type 1 Form Dictionary]
    ## use ISO_32000::Type_1_Form;
    ## also does ISO_32000::Type_1_Form;

    use PDF::COS::Tie;
    use PDF::COS::DateString;
    use PDF::Resources;
    use PDF::COS::Stream;
    use PDF::COS::Name;
    use PDF::Group::Transparency;
    use PDF::OCG;   # optional content group
    use PDF::OCMD;  # optional content membership dict
    my subset OCG-or-OCMD where PDF::OCG|PDF::OCMD;

    has Int $.FormType is entry where 1;    # (Optional) A code identifying the type of form XObject that this dictionary describes. The only valid value is 1.
    has Numeric @.BBox is entry(:required,:len(4)); # (Required) An array of four numbers in the form coordinate system (see above), giving the coordinates of the left, bottom, right, and top edges, respectively, of the form XObject’s bounding box.
    has Numeric @.Matrix is entry(:len(6));         # (Optional) An array of six numbers specifying the form matrix, which maps form space into user space
    has PDF::Resources $.Resources is entry;        # (Optional but strongly recommended; PDF 1.2) A dictionary specifying any resources (such as fonts and images) required by the form XObject
    has PDF::Group::Transparency $.Group is entry;              # (Optional; PDF 1.4) A group attributes dictionary indicating that the contents of the form XObject are to be treated as a group and specifying the attributes of that group
    has Hash $.Ref is entry;                # (Optional; PDF 1.4) A reference dictionary identifying a page to be imported from another PDF file, and for which the form XObject serves as a proxy
    use PDF::Metadata::XML;
    has PDF::Metadata::XML $.Metadata is entry;       # (Optional; PDF 1.4) A metadata stream containing metadata for the form XObject
    has Hash $.PieceInfo is entry;          # (Optional; PDF 1.3) A page-piece dictionary associated with the form XObject
    has PDF::COS::DateString $.LastModified is entry;        # (Required if PieceInfo is present; optional otherwise; PDF 1.3) The date and time when the form XObject’s contents were most recently modified
    has UInt $.StructParent is entry;       # (Required if the form XObject is a structural content item; PDF 1.3) The integer key of the form XObject’s entry in the structural parent tree
    has UInt $.StructParents is entry;      # (Required if the form XObject contains marked-content sequences that are structural content items; PDF 1.3) The integer key of the form XObject’s entry in the structural parent tree
    has Hash $.OPI is entry;                # (Optional; PDF 1.2) An OPI version dictionary for the form XObject

    has OCG-or-OCMD $.OC is entry(:alias<optional-content-group>);                 # (Optional; PDF 1.5) An optional content group or optional content membership dictionary

    has PDF::COS::Name $.Name is entry; # (Required in PDF 1.0; optional otherwise) The name by which this form XObject is referenced in the XObject subdictionary of the current resource dictionary.

    method cb-check {
        die "/LastModified is required when /PieceInfo is present"
            if (self<PieceInfo>:exists) && !(self<LastModified>:exists);
    }
}
