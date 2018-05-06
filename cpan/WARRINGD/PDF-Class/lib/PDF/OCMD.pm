use v6;

use PDF::COS::Dict;
use PDF::Class::Type;

# /Type /OCMD - Optional Content Marked Content
class PDF::OCMD
    is PDF::COS::Dict
    does PDF::Class::Type {

    # see [PDF 32000 14.7.2 Structure Hierarchy]
    use PDF::COS::Tie;
    use PDF::COS::Tie::Hash;
    use PDF::COS::Dict;
    use PDF::COS::Name;
    use PDF::COS::TextString;

    has PDF::COS::Name $.Type is entry(:required) where 'OCMD';

    has $.OCGs is entry where Array|Hash; #| (Optional) A dictionary or array of dictionaries specifying the optional content groups whose states shall determine the visibility of content controlled by this membership dictionary. Null values or references to deleted objects shall be ignored. If this entry is not present, is an empty array, or contains references only to null or deleted objects, the membership dictionary shall have no effect on the visibility of any content.
    has PDF::COS::Name $.P is entry where /^[All|Any][Off|On]$/; #| (Optional) A name specifying the visibility policy for content belonging to this membership dictionary. Valid values shall be:
    #| AllOn visible only if all of the entries in OCGs are ON
    #| AnyOn visible if any of the entries in OCGs are ON
    #| AnyOff visible if any of the entries in OCGs are OFF
    #| AllOff visible only if all of the entries in OCGs are OFF
    #| Default value: AnyOn
    has @.VE is entry;  #| (Optional; PDF 1.6) An array specifying a visibility expression, used to compute visibility of content based on a set of optional content groups
}
