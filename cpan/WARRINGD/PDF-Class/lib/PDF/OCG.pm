use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

#| /Type /OCG - Optional Content Group
class PDF::OCG
    is PDF::COS::Dict
    does PDF::Class::Type {

    # see [PDF 32000 14.7.2 Structure Hierarchy]
    ## use ISO_32000::Optional_Content_Group;
    ## also does ISO_32000::Optional_Content_Group;

    use PDF::COS::Tie;
    use PDF::COS::Tie::Hash;
    use PDF::COS::Dict;
    use PDF::COS::Name;
    use PDF::COS::TextString;

    has PDF::COS::Name $.Type is entry(:required, :alias<type>) where 'OCG';

    has PDF::COS::TextString $.Name is entry(:required);  # (Required) The name of the optional content group, suitable for presentation in a reader’s user interface.
    has PDF::COS::Name @.Intent is entry(:array-or-item, :default<View>); # (Optional) A single intent name or an array containing any combination of names. PDF defines two names, View and Design, that may indicate the intended use of the graphics in the group. A conforming reader may choose to use only groups that have a specific intent and ignore others.
    # Default value: View.

    role Usage
        does PDF::COS::Tie::Hash {
        ## use ISO_32000::Optional_Content_Group_Usage;
        ## also does ISO_32000::Optional_Content_Group_Usage;

        my role CreatorInfo
            does PDF::COS::Tie::Hash {

            has PDF::COS::TextString $.Creator is entry; # A text string specifying the application that created the group.
            has PDF::COS::Name $.Subtype is entry;       # A name defining the type of content controlled by the group.
                # Suggested values include but shall not be limited to Artwork,
                # for graphic-design or publishing applications, and Technical,
                # for technical designs such as building plans or schematics.

                # Additional entries may be included to present information relevant to the
                # creating application or related applications.
                # Groups whose Intent entry contains Design typically include a
                # CreatorInfo entry.
        }
        has CreatorInfo $.CreatorInfo is entry; # Optional) A dictionary used by the creating application to store application-specific data associated with this optional content group.

        my role Language
            does PDF::COS::Tie::Hash {

            has PDF::COS::TextString $.Lang is entry(:required); # A text string that specifies a language and possibly. For example, es-MX represents Mexican Spanish
            has PDF::COS::Name $.Preferred is entry(:default<OFF>) where 'ON'|'OFF';             # name whose values shall be either ON or OFF. Default value: OFF.
        }
        has Language $.Language is entry; # Optional) A dictionary specifying the language of the content controlled by this optional content group. I
        my subset ON-or-OFF of PDF::COS::Name where 'ON'|'OFF';

        my role Export
        does PDF::COS::Tie::Hash {
            has ON-or-OFF $.ExportState is entry(:default<OFF>);             # name whose values shall be either ON or OFF. Default value: OFF.
        }
        has Export $.Export is entry; # This value shall indicate the recommended state for content in this group when the document (or part of it) is saved by a conforming reader to a format that does not support optional content (for example, a raster image format).

        my role Zoom
            does PDF::COS::Tie::Hash {
            has Numeric $.min is entry(:default(0)); # The minimum recommended magnification factor at which the group shall be ON. Default value: 0.
            has Numeric $.max is entry; # The magnification factor below which the group shall be ON. Default value: infinity.
        }
        has Zoom $.Zoom is entry; # Optional) A dictionary specifying a range of magnifications at which the content in this optional content group is best viewed.

        my role Print
            does PDF::COS::Tie::Hash {
            has PDF::COS::Name $.Subtype is entry; # A name object specifying the kind of content controlled by the group; for example, Trapping, PrintersMarks and Watermark.
            has ON-or-OFF $.PrintState is entry;             # A name that shall be either ON or OFF, indicating that the group shall be set to that state when the document is printed from a conforming reader.
        }
        has Print $.Print is entry; # Optional) A dictionary specifying that the content in this group is shall be used when printing.

        my role View
            does PDF::COS::Tie::Hash {
            has ON-or-OFF $.ViewState is entry(:default<OFF>);             # name whose values shall be either ON or OFF. Default value: OFF.
        }
        has View $.View is entry;

        my role User
            does PDF::COS::Tie::Hash {
            has PDF::COS::Name $.Type is entry; # A name object that shall be either Ind (individual), Ttl (title), or Org (organization).
            has PDF::COS::TextString @.Name is entry;              # A text string or array of text strings representing the name(s) of the individual, position or organization.
        }
        has User $.User is entry; # Optional) A dictionary specifying one or more users for whom this optional content group is primarily intended

        my role PageElement
            does PDF::COS::Tie::Hash {
            has PDF::COS::Name $.Subtype is entry where 'HF'|'FG'|'BG'|'L';
        }
        has PageElement $.PageElement is entry; # A dictionary declaring that the group contains a pagination artifact. It shall contain one entry, Subtype, whose value shall be a name that is either HF (header/footer), FG (foreground image or graphic), BG (background image or graphic), or L (logo).
    }
    has Usage $.Usage is entry;

}
